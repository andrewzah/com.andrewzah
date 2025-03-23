{
  description = "Builds a Quartz website and Docker image.";
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

        hugo_145 = pkgs.hugo.overrideAttrs (prevAttrs: rec {
          version = "0.145.0";

          src = pkgs.fetchFromGitHub {
            owner = "gohugoio";
            repo = "hugo";
            tag = "v${version}";
            hash = "sha256-5SV6VzNWGnFQBD0fBugS5kKXECvV1ZE7sk7SwJCMbqY=";
          };

          vendorHash = "sha256-aynhBko6ecYyyMG9XO5315kLerWDFZ6V8LQ/WIkvC70=";
        });
      in {
        packages = rec {
          website = pkgs.stdenv.mkDerivation {
            name = "andrewzah-hugo-website";
            src = ./.;
            nativeBuildInputs = (with pkgs; [git hugo_145 go]);

            buildPhase = let
              hugoVendor = pkgs.stdenv.mkDerivation {
                name = "andrewzah-hugo-website-vendor";
                src = ./.;
                nativeBuildInputs = (with pkgs; [ go git hugo_145 ]);

                buildPhase = ''
                  cd src
                  hugo mod vendor
                '';

                installPhase = ''
                  cp -r _vendor $out
                '';

                outputHash = "sha256-IWeh65+iMET/9iKjhQEVLkCpiwRA6I3se3xFjp4q360=";
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
            in pkgs.buildEnv {
              name = "img-root";
              paths = [caddyfile website];
              pathsToLink = ["/bin" "/etc" "/var"];
            };

            config = {
              Cmd = [ "${pkgs.caddy}/bin/caddy" "run" "--config" "/etc/caddy/Caddyfile" "--adapter"  "caddyfile" ];
              ExposedPorts = { "2020" = {}; };
            };
          };
        };

        devShells.default = pkgs.mkShell {
          packages = (with pkgs; [
            hugo_145
            go

            awscli2
            typos
            lychee # link checker
          ]);
          shellHook = ''
            alias v="nvim";
            alias j="just";
          '';
        };
      }
    );

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";

    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";
  };
}
