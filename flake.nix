{
  description = "hugo website and oci container";
  outputs = {
    self,
    nixpkgs,
    nix2container,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        n2c = nix2container.packages."${system}".nix2container;
      in {
        packages = rec {
          website = pkgs.stdenv.mkDerivation {
            name = "andrewzah-hugo-website";
            src = ./.;
            nativeBuildInputs = with pkgs; [git hugo go];

            buildPhase = let
              hugoVendor = pkgs.stdenv.mkDerivation {
                name = "andrewzah-hugo-website-vendor";
                src = ./.;
                nativeBuildInputs = with pkgs; [go git hugo];

                buildPhase = ''
                  cd src
                  hugo mod vendor
                '';

                installPhase = ''
                  cp -r _vendor $out
                '';

                outputHash = "sha256-pQpattmS9VmO3ZIQUFn66az8GSmB4IvYhTTCFn6SUmo=";
                outputHashAlgo = "sha256";
                outputHashMode = "recursive";
              };
            in ''
              ln -s ${hugoVendor} src/_vendor
              ls -la src/_vendor
              cd ./src
              hugo --minify
            '';

            installPhase = ''
              mkdir -p $out/var/www
              cp -r ./public $out/var/www/com.andrewzah
            '';

            dontFixup = true;
          };

          container = n2c.buildImage {
            name = "docker.io/andrewzah/com-andrewzah";
            tag = "latest";

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
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            hugo
            go

            awscli2
            typos
            lychee # link checker
          ];
        };
      }
    );

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";
  };
}
