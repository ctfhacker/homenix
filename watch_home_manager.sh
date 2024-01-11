#! /usr/bin/env nix-shell
#! nix-shell -i bash -p inotify-tools

while inotifywait \
    -e close_write ./profiles/default/home.nix \
    -e close_write flake.nix \
    -e close_write ./profiles/default/configuration.nix; do 
  sudo nixos-rebuild build --flake .#default --show-trace
  home-manager build --flake .#user
done
