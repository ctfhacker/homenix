  # Edit this configuration file to define what should be installed on
  # your system.  Help is available in the configuration.nix(5) man page
  # and in the NixOS manual (accessible by running ‘nixos-help’).

  { lib, config, pkgs, inputs, username, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ../../system/hardware-configuration.nix

      # Import home-manager
      inputs.home-manager.nixosModules.default
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos"; # Define your hostname.
  networking.extraHosts = ''
    127.0.0.1 cernvax.cern.ch
  '';
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # sound.enable = true;
  hardware.pulseaudio.enable = lib.mkForce false;
  sound.enable = false;
  security.rtkit.enable = config.services.pipewire.enable;
  services.pipewire = {
    enable = true;
    audio.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # links /libexec from derivations to /run/current-system/sw
  environment.pathsToLink = ["/libexec"];

  # Configure keymap in X11
  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "";
    xkbOptions = "ctrl:swapcaps";

    desktopManager.xterm.enable    = false;
    displayManager.defaultSession  = "none+i3";
    displayManager.gdm.autoSuspend = false;

    windowManager.i3  = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu         # Application loader
        i3status-rust # Status bar
        i3lock        # Lock screen
      ];
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    name = username;
    home = "/home/" + username;
    extraGroups = [ "networkmanager" "wheel" "audio" "video" "docker" "kvm" "libvirtd" ];
    packages = with pkgs; [];
    uid = 1000;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     helix 
     wget
     tmux
     git
     alsa-utils
     pulseaudio
     pavucontrol
     usbutils
     ddcutil
     home-manager

     # Research/analysis tools
     # gdb
     # pwndbg
  ];

  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
    font-awesome
    liberation_ttf
  ];

  # home-manager = {
  #   extraSpecialArgs = { 
  #     inherit inputs; 
  #     inherit username;
  #   };

  #   users = {
  #     username = import ./home.nix;
  #   };
  # };

  # Disable auto-suspend feature in GNOME
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # Enable virtualisation for docker daemon
  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;

  programs.steam = {
    enable = true;
  };

  programs.nix-ld = {
    enable = true;

    libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      fuse3
      icu
      zlib
      nss
      openssl
      curl
      expat
    ];
  };

  # OBS Studio config with virtualcam
  # https://nixos.wiki/wiki/OBS_Studio
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
  '';
  security.polkit.enable = true;

  boot.binfmt.emulatedSystems = [ "riscv64-linux" "aarch64-linux" ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
