#! /usr/bin/env nix-shell
#! nix-shell -i bash -p inotify-tools

while inotifywait -e close_write ./hosts/default/home.nix -e close_write flake.nix; do 
  sudo nixos-rebuild switch --flake .#default
done
