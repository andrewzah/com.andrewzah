b:
  marmite -w src/ dist

s:
  marmite --serve -w src/ dist

db:
  nix run .#container.copyToDockerDaemon

nd:
  nix develop --profile /tmp/com-andrewzah-profile
