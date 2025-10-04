# Nix configuration

## Rebuild NixOS

```
sudo nixos-rebuild switch --flake .
```

## Switch home manager

```
# On Linux
home-manager switch --flake .#user

# On macOS
home-manager switch --flake '.#user-macos'
```
