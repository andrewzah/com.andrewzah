{ pkgs ? import <nixpkgs>{} }:
pkgs.mkShell {
  packages = [
    pkgs.quartoMinimal
    (pkgs.texliveTeTeX.withPackages (ps: [ ps.framed ]))
    (pkgs.python3.withPackages (ps: with ps; [ pyyaml notebook ]))
  ];
  shellHook = ''
    echo "Loaded Quarto dev shell!"
    alias v='nvim'
    alias j='just'
  '';
}