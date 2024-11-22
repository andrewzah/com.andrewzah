{ pkgs ? import <nixpkgs> {
    config = {
      allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [ "rust-rover" "vscode" "vscode-with-extensions" ];
    };
  }
}: let
  profile = "stable";

  fenix = pkgs.callPackage
    (pkgs.fetchFromGitHub {
      owner = "nix-community";
      repo = "fenix";
      # commit from: 2024-11-15
      rev = "664e2f335aa5ae28c8759ff206444edb198dc1c9";
      hash = "sha256-vau17dcGvfEWX9DLWuSPC0dfE0XcDe9ZNlsqXy46P88=";
    }) {};

  targets = [
    "aarch64-apple-ios"
    "aarch64-apple-ios-sim"
    "x86_64-apple-ios"

    "armv7-linux-androideabi"
    "i686-linux-android"
    "aarch64-linux-android"
    "x86_64-linux-android"
    "x86_64-unknown-linux-gnu"
    "x86_64-apple-darwin"
    "aarch64-apple-darwin"
    "x86_64-pc-windows-gnu"
    "x86_64-pc-windows-msvc"

    "wasm32-unknown-unknown"
  ];

  rustToolchain = fenix.combine [
    fenix.stable.toolchain
    (map (t: fenix.targets.${t}.${profile}.rust-std) targets)
  ];
in
pkgs.mkShell {
  name = "my-rust-env";
  packages = [
    rustToolchain

    pkgs.pkg-config
    pkgs.openssl
    pkgs.wasm-pack

    (pkgs.vscode-with-extensions.override {
      vscodeExtensions = (with pkgs.vscode-extensions; [
        bbenoist.nix
        christian-kohler.path-intellisense
        rust-lang.rust-analyzer
      ]);
    })

    pkgs.jetbrains.rust-rover
  ];

  shellHook = ''
    export RUST_BRACKTRACE=1;
  '';
}
