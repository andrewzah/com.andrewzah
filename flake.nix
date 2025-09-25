{
  description = "hugo website and oci container";
  outputs = {
    nixpkgs,
    nix2container,
    self,
  }: let
    systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
    forEachSystem = f:
      builtins.listToAttrs (map (system: {
          name = system;
          value = f system;
        })
        systems);
  in {
    packages = forEachSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      n2c = nix2container.packages."${system}".nix2container;

      # currently 0.2.5, need 0.2.6 for template override
      marmite = pkgs.callPackage ./marmite.nix {inherit pkgs;};
    in rec {
      website = pkgs.stdenv.mkDerivation {
        name = "com-andrewzah-blog-dist";
        version = "2025-09-25";

        nativeBuildInputs = [marmite];
        src = pkgs.lib.fileset.toSource {
          root = ./.;
          fileset = pkgs.lib.fileset.unions [./src];
        };

        postPatch = ''
          # don't include draft posts at all, WTF!
          grep -rl 'stream: "draft"' . | xargs rm
        '';

        buildPhase = ''
          marmite src/ dist
        '';

        installPhase = ''
          mkdir -p $out/var/www
          cp -R dist $out/var/www/com.andrewzah.blog
        '';
      };

      container = n2c.buildImage {
        name = "docker.io/andrewzah/com-andrewzah-blog";
        tag = "2025-09-25";

        copyToRoot = let
          caddyfile = pkgs.writeTextDir "/etc/caddy/Caddyfile" (builtins.readFile ./Caddyfile);
        in
          pkgs.buildEnv {
            name = "img-root";
            paths = [caddyfile website];
            pathsToLink = ["/bin" "/etc" "/var"];
          };

        config = {
          Cmd = ["${pkgs.caddy}/bin/caddy" "run" "--config" "/etc/caddy/Caddyfile" "--adapter" "caddyfile"];
          ExposedPorts = {"2020" = {};};
        };
      };
    });

    devShells = forEachSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      marmite = pkgs.callPackage ./marmite.nix {inherit pkgs;};
    in {
      default = pkgs.mkShell {
        buildInputs = [marmite];
      };
    });
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix2container.url = "github:andrewzah/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";
  };
}
