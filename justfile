b:
  nix build .#website

c:
  nix run .#container.copyToDockerDaemon

dr:
  docker run --rm -it \
    -p 2020:2020 \
    docker.io/andrewzah/com-andrewzah:latest

u:
  nix flake lock --update-input quartz-src

l:
  lychee --cache content/posts/*.md
