b:
  nix run .#container.copyToDockerDaemon

p:
  docker push docker.io/andrewzah/com-andrewzah:latest
