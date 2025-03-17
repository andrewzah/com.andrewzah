d:
  nix develop --profile /tmp/com-andrewzah-profile

db:
  nix run .#container.copyToDockerDaemon

do:
  just docker-build
  just docker-push

dp:
  docker push andrewzah/personal_site:latest
