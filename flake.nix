{
  description = "andrewzah.com shell + docker image with Quarto/LaTeX/python";

  inputs = {
    nix2container.url = "github:nlewo/nix2container";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nix2container, flake-utils, nixpkgs, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        n2c = nix2container.packages."${system}".nix2container;
      in {
        packages = {
          container = n2c.buildImage {
            name = "docker.io/andrewzah/com-andrewzah";
            tag = "latest";

            copyToRoot = let
              caddyfile = pkgs.writeTextDir "/etc/caddy/Caddyfile" (builtins.readFile ./Caddyfile);
            in
            pkgs.buildEnv {
              name = "img-root";
              paths = [
                caddyfile
                (pkgs.callPackage ./static-site.nix {
                  inherit pkgs;
                })
              ];
              pathsToLink = [ "/bin" "/etc" "/var" ];
            };

            config = {
              Cmd = [ "${pkgs.caddy}/bin/caddy" "run" "--config" "/etc/caddy/Caddyfile" "--adapter"  "caddyfile" ];
              ExposedPorts = { "2020" = {}; };
            };
          };
        };

        devShells = rec {
          default = dev;
          dev = pkgs.mkShell {
            paths = [
              pkgs.quartoMinimal
              (pkgs.texliveTeTeX.withPackages (ps: with ps; [
                framed
              ]))
              #(pkgs.python3.withPackages (ps: with ps; [ jupyter matplotlib plotly ]))
              #d2
              #gnuplot
            ];
          };
        };
      }
    );
}
