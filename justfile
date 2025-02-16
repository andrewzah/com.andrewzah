b:
  nix build .#website

c:
  nix run .#container.copyToDockerDaemon
