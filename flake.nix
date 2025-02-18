{
  description = "Builds a Quartz website and Docker image.";
  outputs = {
    self,
    nixpkgs,
    nix2container,
    flake-utils,
    quartz-src,
    language-servers,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        n2c = nix2container.packages."${system}".nix2container;
      in {
        packages = rec {
          website = let
            npmBuild = pkgs.buildNpmPackage {
              name = "quartz";
              npmDepsHash = "sha256-5v0VEK5X4YMcWGTdaKg+Q0gdgwERZzbx1TMFj33k3BE=";
              src = quartz-src;
              dontNpmBuild = true;

              installPhase = ''
                runHook preInstall
                npmInstallHook

                cd $out/lib/node_modules/@jackyzha0/quartz
                rm -rf ./content

                mkdir content
                cp -r ${./content}/* ./content

                $out/bin/quartz build
                mv ./public $out/public

                runHook postInstall
              '';
            };
          in pkgs.stdenv.mkDerivation {
            name = "andrewzah-quartz-website";
            src = ./content;

            installPhase = ''
              mkdir -p $out/var/www
              cp -r ${npmBuild}/public/ $out/var/www/com.andrewzah
            '';
          };

          container = n2c.buildImage {
            name = "docker.io/andrewzah/com-andrewzah";
            tag = "latest";

            copyToRoot = let
              caddyfile = pkgs.writeTextDir "/etc/caddy/Caddyfile" (builtins.readFile ./Caddyfile);
            in pkgs.buildEnv {
              name = "img-root";
              paths = [
                caddyfile
                website
                pkgs.bashInteractiveFHS
              ];
              pathsToLink = [ "/bin" "/etc" "/var" ];
            };

            config = {
              Cmd = [ "${pkgs.caddy}/bin/caddy" "run" "--config" "/etc/caddy/Caddyfile" "--adapter"  "caddyfile" ];
              ExposedPorts = { "2020" = {}; };
            };
          };
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            nodejs_22
            prettierd
            eslint_d
            language-servers.packages.${system}.typescript-language-server
          ];
        };
      }
    );

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";

    quartz-src = {
      #url = "github:jackyzha0/quartz/v4";
      #url = "github:andrewzah/quartz/v4";
      url = "git+file:///home/dragon/programming/quartz";
      flake = false;
    };

    language-servers.url = "git+https://git.sr.ht/~bwolf/language-servers.nix";
    language-servers.inputs.nixpkgs.follows = "nixpkgs";

    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";
  };
}
