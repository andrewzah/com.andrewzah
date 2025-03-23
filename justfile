db:
  nix run .#container.copyToDockerDaemon

nd:
  nix develop --profile /tmp/com-andrewzah-profile

do:
  just docker-build
  just docker-push

dp:
  docker push docker.io/andrewzah/com-andrewzah:latest
