#!/usr/bin/env bash

# Add basic prereqs
sudo apt install git curl tmux

# Install nix
sh <(curl -L https://nixos.org/nix/install) --no-daemon
. "$HOME/.nix-profile/etc/profile.d/nix.sh"

# Install home-manager
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install

# Enable nix-command and flake features
mkdir -p $HOME/.config/nix
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf

# Change the user to the current user
sed -i "s/username = \"user\"/username = \"$USER\"/" flake.nix

# Install the configs via home-manager
home-manager switch --flake .#user
