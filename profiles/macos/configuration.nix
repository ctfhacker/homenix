{ config, pkgs, lib, inputs, username, ... }:

let
  hostName = "MacBook-Pro";
  userHome = "/Users/${username}";

  packageFor = pkgSet: defaultPkg:
    let
      systemPkgs = lib.attrByPath [ pkgs.system ] {} pkgSet;
    in lib.attrByPath [ "default" ] defaultPkg systemPkgs;
in {
  networking.hostName = hostName;
  system.stateVersion = 5;
  system.primaryUser = username;

  nix.package = pkgs.nix;
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" username ];
  };

  programs.zsh.enable = true;

  users.users.${username} = {
    name = username;
    home = userHome;
    shell = pkgs.zsh;
  };

  environment = {
    shells = [ pkgs.zsh pkgs.bashInteractive ];
    systemPackages = with pkgs; [
      git
      ripgrep
      fd
      jq
      starship
      tmux
      (packageFor inputs.helix.packages pkgs.helix)
    ];
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = { inherit inputs username; };
  home-manager.users.${username} = import ../default/home.nix;

  system.defaults.NSGlobalDomain = {
    AppleShowAllExtensions = true;
    NSAutomaticCapitalizationEnabled = false;
    NSAutomaticSpellingCorrectionEnabled = false;
    NSDocumentSaveNewDocumentsToCloud = false;
  };
}
