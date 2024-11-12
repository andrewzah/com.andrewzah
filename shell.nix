{ pkgs ? import <nixpkgs>{} }:
pkgs.mkShell {
  packages = [
    pkgs.quartoMinimal
    (pkgs.texliveTeTeX.withPackages (ps: with ps; [
      framed
    ]))
    (pkgs.python3.withPackages (ps: with ps; [ jupyter matplotlib plotly ]))
  ];
}
