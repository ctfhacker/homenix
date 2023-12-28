#! /usr/bin/env nix-shell
#! nix-shell -i bash -p inotify-tools

while inotifywait -e close_write ./home-manager/home.nix; do 
  home-manager switch --flake ./home-manager/home.nix; 
done
