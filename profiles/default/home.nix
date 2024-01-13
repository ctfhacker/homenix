{ config, pkgs, lib, outputs, inputs, specialArgs, options, modulesPath, nixosConfig, osConfig, username }:

let
  i3_mod = "Mod1"; # Left Alt/Option
  has_gui = true;
in {
  # Use home manager
  programs.home-manager.enable = true;

  home.username = username;
  home.homeDirectory = "/home/" + username;
  home.stateVersion = "23.11";
  home.packages = with pkgs; [
    alacritty # Terminal emulator
    bat       # Better cat
    docker    # Containers
    fd        # Better find
    helix     # Editor
    hexyl     # Better xxd
    htop      # Process monitoring
    gnumake   # make
    man-pages # Man pages
    man-pages-posix # Man pages
    less      # Less is more
    lsd       # Better ls
    nil       # Nix Language Server
    radare2   # CLI Disassembly
    ripgrep   # Better grep
    unzip     # unzip
    zip       # zip

    # C
    clang     # Compiler
    clang-tools_16 # clangd, clang-format
    vscode-extensions.llvm-org.lldb-vscode # Debug adapter for helix

    # Virtualization
    virt-manager
    libvirt
    qemu

    # Rust
    rustc
    cargo
    cargo-watch
    rustfmt
    rust-analyzer
    clippy
  ] 
  ++ lib.optionals stdenv.isLinux [
    xorg.libX11
  ];

  # Enable vim mode in bash with a couple custom keybindings
  home.file.".inputrc".text = ''
  set editing-mode vi
  set keymap vi-command
  # set show-mode-in-prompt on
  $if mode=vi
    # Normal mode
    set keymap vi-command
    "H": beginning-of-line
    "L": end-of-line
    "j": history-search-forward
    "k": history-search-backward
    set keymap vi-insert
    "jk": vi-movement-mode
  $endif
  set expand-tilde on
  '';
 
  xsession.windowManager.i3 = {
    enable = true;
    config = {
      modifier = i3_mod;

      keybindings = lib.mkOptionDefault {
        # Focus
        "${i3_mod}+h" = "focus left";
        "${i3_mod}+j" = "focus down";
        "${i3_mod}+k" = "focus up";
        "${i3_mod}+l" = "focus right";

        # Move
        "${i3_mod}+Shift+h" = "move left";
        "${i3_mod}+Shift+j" = "move down";
        "${i3_mod}+Shift+k" = "move up";
        "${i3_mod}+Shift+l" = "move right";
      };

      bars = [
        {
          position = "bottom";
          statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-bottom.toml";
        }
       ];
    };
  };

  # Default virt-manager config
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };

  ####################################################################
  ### Programs to enable                                           ###
  ####################################################################
  programs.autorandr = {
    enable = has_gui;

    profiles = {
      "default" = {
        fingerprint = {
          "DP-5" = "00ffffffffffff005a63363201010101071f0104a5351e783f05f5a557529c270b5054bfef80b300a940a9c0950090408180814081c0023a801871382d40582c45000f282100001e000000ff00564c383231303741303633340a000000fd00304b535311010a202020202020000000fc005641323435362053657269657301e002031af14d010203040590121113141e1d1f23097f07830100006842806a70382740082098040f282100001e011d8018711c1620582c25000f282100009e023a80d072382d40102c45800f282100001e011d007251d01e206e2855000f282100001e011d00bc52d01e20b82855400f282100001e0000000000000000000000a6";
          "DP-6" = "00ffffffffffff005a63363201010101071f0104a5351e783f05f5a557529c270b5054bfef80b300a940a9c0950090408180814081c0023a801871382d40582c45000f282100001e000000ff00564c383231303741303539310a000000fd00304b535311010a202020202020000000fc005641323435362053657269657301de02031af14d010203040590121113141e1d1f23097f07830100006842806a70382740082098040f282100001e011d8018711c1620582c25000f282100009e023a80d072382d40102c45800f282100001e011d007251d01e206e2855000f282100001e011d00bc52d01e20b82855400f282100001e0000000000000000000000a6";
          "DP-7" = "00ffffffffffff005a63363201010101071f0104a5351e783f05f5a557529c270b5054bfef80b300a940a9c0950090408180814081c0023a801871382d40582c45000f282100001e000000ff00564c383231303741303538380a000000fd00304b535311010a202020202020000000fc005641323435362053657269657301d802031af14d010203040590121113141e1d1f23097f07830100006842806a70382740082098040f282100001e011d8018711c1620582c25000f282100009e023a80d072382d40102c45800f282100001e011d007251d01e206e2855000f282100001e011d00bc52d01e20b82855400f282100001e0000000000000000000000a6";
          "DP-8" = "00ffffffffffff005a63363201010101071f0104a5351e783f05f5a557529c270b5054bfef80b300a940a9c0950090408180814081c0023a801871382d40582c45000f282100001e000000ff00564c383231303741303630370a000000fd00304b535311010a202020202020000000fc005641323435362053657269657301e002031af14d010203040590121113141e1d1f23097f07830100006842806a70382740082098040f282100001e011d8018711c1620582c25000f282100009e023a80d072382d40102c45800f282100001e011d007251d01e206e2855000f282100001e011d00bc52d01e20b82855400f282100001e0000000000000000000000a6";
        };
        config = {
          "DP-1-1" = {
            enable = false;
          };
          "DP-1-2" = {
            enable = false;
          };          
          "DP-1-3" = {
            enable = false;
          };
          "DP-1-4" = {
            enable = false;
          };
          "DP-5" = {
            enable = true;
            crtc = 0;
            mode = "1920x1080";
            primary = true;
            rate = "60.00";
            position = "0x1080";
          };
          "DP-6" = {
            enable = true;
            crtc = 1; 
            mode = "1920x1080";
            rate = "60.00";
            position = "0x0";
            rotate = "inverted";
          };
          "DP-7" = {
            enable = true;
            crtc = 2; 
            mode = "1920x1080";
            rate = "60.00";
            position = "1920x0";
            rotate = "left";      
          };
          "DP-8" = {
            enable = true;
            crtc = 3; 
            mode = "1920x1080";
            rate = "60.00";
            position = "3000x0";
            rotate = "right";          
          };
        };
      };
    };
  };

  programs.bash = {
    enable = true;
    bashrcExtra = ''
    if [ "$TMUX" = "" ]; then TERM=screen-256color; tmux -2; fi
    '';

    shellAliases = {
      ".." = "cd ..";
      "..." = "cd ../..";
      "rm" = "rm -i"; # Always prompt before a deletion
      "cp" = "cp -i"; # Always prompt before a deletion
      "vim" = "hx";
      "cat" = "bat --theme \"Solarized (dark)\"";
      "l" = "lsd -lah";
      "ls" = "lsd";
      "ll" = "lsd -la";
      "tree" = "lsd -la --tree";
      "goto_mac" = "for b in 35 36; do sudo ddcutil --bus $b setvcp 60 17; done";
      "goto_nix" = "for b in 35 36; do sudo ddcutil --bus $b setvcp 60 15; done";
      "pull_nix" = "pushd ~/homenix ; git stash ; git pull ; git stash apply ; home-manager switch --flake .#user ; popd";
      "nixnix" = "source $HOME/.nix-profile/etc/profile.d/nix.sh";
      "xxd" = "hexyl";
      "reload" = "source ~/.bash_profile";
    };
  };

  programs.firefox.enable = has_gui;
  programs.firefox = {
    profiles.user = {
        extensions = with inputs.firefox-addons.packages."x86_64-linux"; [
          bitwarden
          darkreader
          ublock-origin
          sponsorblock
          vimium
        ];

        bookmarks = [
          
        ];

        settings = {
          "app.update.auto" = true;
          "browser.startup.homepage" = "https://lobste.rs";
          "browser.urlbar.placeholderName" = "DuckDuckGo";
          "services.sync.declinedEngines" = "addons,passwords,prefs";
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;
          "privacy.trackingprotection.socialtracking.annotate.enabled" = true;
        };

        search = {
          force = true;
          default = "DuckDuckGo";
          order = [ "DuckDuckGo" "Google" ];

          engines = {
            "Nix Packages" = {
              urls = [
                {
                  template = "https://search.nixos.org/packages";
                  params = [
                    {
                      name = "type";
                      value = "packages";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];

              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = ["@np"];
            };

            "NixOS Wiki" = {
              urls = [{template = "https://nixos.wiki/index.php?search={searchTerms}";}];
              iconUpdateURL = "https://nixos.wiki/favicon.png";
              updateInterval = 24 * 60 * 60 * 1000; # every day
              definedAliases = ["@nw"];
            };
          };
        };
      };
    };

  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "Cory Duplantis";
    userEmail = "cld251@gmail.com";
    aliases = {
      s = "status";
      co = "checkout";
      cob = "checkout -b";
      d = "diff --color=always";
    };
  };

  programs.helix = {
    enable = true;
    settings = {
      theme = "solarized_dark";

      editor = {
        line-number = "relative";
        color-modes = true;
        true-color = true;
        gutters = [
          "diagnostics"
          "line-numbers"
          "spacer"
          "diff"
        ];
        lsp.display-inlay-hints = true;
        rulers = [ 110 ];
        smart-tab.enable = true;
        soft-wrap.enable = true;
        statusline = {
          left = [
            "mode"
            "spinner"
            "version-control"
            "file-name"
            "file-modification-indicator"
            "read-only-indicator"
          ];
          center = [ ];
          right = [
            "register"
            "file-type"
            "diagnostics"
            "selections"
            "position"
            "position-percentage"
          ];
        };
        whitespace = {
          render.space = "all";
          render.tab = "all";
          # render.newline = "all";
          characters.space = " ";
          characters.nbsp = "⍽";
          characters.tab = "→";
          # characters.newline = "⏎";
          characters.tabpad = "-";
        };
      };

      keys.normal = {
        H = "goto_first_nonwhitespace";
        L = "goto_line_end";
        S = "split_selection_on_newline";
      };
      keys.select = {
        H = "goto_line_start";
        x = "extend_line";        # Same as normal
        V = "extend_to_line_end"; # Same as normal
      };
      keys.insert = {
        j.k = "normal_mode";
      };
    };
  };


  programs.i3status-rust = {
    enable = true;
    bars = {
      bottom = {
        theme = "solarized-dark";
        icons = "none";
        blocks = [
          {
            block = "sound";
          }
          {
            block = "cpu";
            interval = 1;
            format = "$icon $barchart $utilization";
          }
          {
            block = "memory";
            interval = 5;
            format = "$icon $mem_used_percents";
          }
          {
            block = "disk_space";
            warning = 15.0;
            alert = 10.0;
            alert_unit = "GB";
            interval = 30;
            format = "$icon $available";
          }
          {
            block = "net";
            interval = 10;
            format = "$icon $ip";
          }
          {
            block = "time";
            interval = 1;
            format = "$icon $timestamp.datetime(f:'%a %Y/%m/%d %I:%M%p')";
          }
        ];
      };
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      username.show_always = true;
      memory_usage.disabled = false;
      time.disabled = false;
    };
  };

  programs.tmux = {
    enable = true;
    prefix = "C-a";
    secureSocket = true; # Sets socket in /run instead of /tmp
    escapeTime = 0;
    aggressiveResize = true;
    historyLimit = 256000;
    keyMode = "vi";
    extraConfig = ''
    set -g repeat-time 0

    bind h select-pane -L
    bind j select-pane -D
    bind k select-pane -U
    bind l select-pane -R

    bind -r H resize-pane -L 10
    bind -r J resize-pane -D 10
    bind -r K resize-pane -U 10
    bind -r L resize-pane -R 10

    # Allows to use C-a a <command> to send commands to a nested TMUX
    bind-key a send-prefix
    bind-key - split-window
    bind-key \\ split-window -h
    '';
  };

  }
