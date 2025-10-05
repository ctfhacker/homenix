{ config, pkgs, lib, outputs, inputs, specialArgs, options, modulesPath, nixosConfig, osConfig, username, _class, _prefix, ...}:

let
  inherit (pkgs) stdenv;

  system = stdenv.hostPlatform.system;
  isLinux = stdenv.isLinux;
  isDarwin = stdenv.isDarwin;

  i3_mod = "Mod1"; # Left Alt/Option
  has_gui = true;

  packageFor = pkgSet: default:
    let
      systemPkgs = lib.attrByPath [ system ] null pkgSet;
    in if systemPkgs == null then default else lib.attrByPath [ "default" ] default systemPkgs;

  my_helix = packageFor inputs.helix.packages pkgs.helix;
  pwndbg = packageFor inputs.pwndbg.packages null;
  starship_jj = packageFor inputs.starship-jj.packages null;
  cursor = packageFor inputs.cursor.packages null;
  firefoxAddons = lib.attrByPath [ system ] {} inputs.firefox-addons.packages;

  optionalInputPkgs = builtins.filter (pkg: pkg != null) [ my_helix starship_jj ];
  optionalLinuxPkgs = builtins.filter (pkg: pkg != null) [ pwndbg cursor ];

in {
  # Use home manager
  programs.home-manager.enable = true;

  home.username = username;
  home.homeDirectory = if isDarwin then "/Users/${username}" else "/home/" + username;
  home.stateVersion = "25.05";
  home.packages =
    let
      common = with pkgs; [
        bacon
        bat
        cmake
        delta
        entr
        fd
        file
        ffmpeg
        glow
        hexyl
        gnumake
        htop
        jless
        jq
        jujutsu
        less
        lsd
        nil
        radare2
        ripgrep
        starship
        tmux
        unzip
        zip
        clang
        clang-tools_16
        liberation_ttf
        dejavu_fonts
        (python3.withPackages (ps:
          with ps; [
            ipython
            ipdb
            pip
            python-lsp-server
            mypy
          ]))
      ] ++ optionalInputPkgs;

      linuxOnly = with pkgs; [
        cmus
        docker
        flameshot
        google-chrome
        lsp-ai
        man-pages
        man-pages-posix
        musescore
        xclip
        stdenv.cc.cc.lib
        (writeShellScriptBin "x-www-browser" ''
          exec firefox "$@"
        '')
        (pkgs.callPackage ../../packages/binaryninja {})
        vscode-extensions.llvm-org.lldb-vscode
      ] ++ optionalLinuxPkgs;

      darwinOnly = with pkgs; [
      ];
    in common
    ++ lib.optionals isLinux linuxOnly
    ++ lib.optionals isDarwin darwinOnly
    ++ lib.optionals isLinux [ pkgs.xorg.libX11 ];

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
 
  xsession.windowManager.i3 = lib.mkIf (has_gui && isLinux) {
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
  # dconf.settings = {
    # "org/virt-manager/virt-manager/connections" = {
      # autoconnect = ["qemu:///system"];
      # uris = ["qemu:///system"];
    # };
  # };


  ####################################################################
  ### Programs to enable                                           ###
  ####################################################################
  programs.alacritty = {
    enable = true;

    settings = {
      selection.save_to_clipboard = true;
      };
  };

  programs.autorandr = lib.mkIf (has_gui && isLinux) {
    enable = true;

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

  programs.bash = lib.mkIf isLinux {
    enable = true;
    bashrcExtra = ''
    if [ "$TMUX" = "" ]; then TERM=screen-256color; tmux -2; fi
    eval "$(direnv hook bash)"
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
      "goto_nix" = "for f in $(sudo ddcutil detect  | rg i2c | rev | cut -d'-' -f1 | rev); do sudo ddcutil --bus $f setvcp 60 15; done";
      # "goto_mac" = "for f in $(sudo ddcutil detect  | rg i2c | rev | cut -d'-' -f1 | rev); do sudo ddcutil --bus $f setvcp 60 17; done";
      "goto_mac" = "sudo ddcutil --bus 10 setvcp 60 17";
      "pull_nix" = "pushd ~/homenix ; git stash ; git pull ; git stash apply ; home-manager switch --flake .#user ; popd";
      "nixnix" = "source $HOME/.nix-profile/etc/profile.d/nix.sh";
      "xxd" = "hexyl";
      "reload" = "source ~/.bash_profile";
      "mirror" = "xrandr --output eDP-1 --mode 1920x1080 --output HDMI-1 --mode 1920x1080 --same-as eDP-1";
      "cargo_init" = "nix flake new --template github:ctfhacker/cargo_init#rust";
      "jjl" = "jj log -r '::'";
    };
  };

  # Enable direnv to allow switching nix-shells on going to a new directory
  programs.direnv = {
    enable = true;
    enableBashIntegration = isLinux;
    enableZshIntegration = isDarwin;
    nix-direnv.enable = true;
  };

  programs.zsh = lib.mkIf isDarwin {
    enable = true;
    autocd = true;
    shellAliases = {
      ll = "ls -la";
      vim = "hx";
      gs = "git status";
      home-switch = "darwin-rebuild switch --flake ~/homenix#MacBook-Pro";
      hm-switch = "home-manager switch --flake ~/homenix#${username}-macos";
      
    };
    initExtra = ''
# Enable vi keybindings
bindkey -v

# Command mode keybindings
bindkey -M vicmd 'H' beginning-of-line
bindkey -M vicmd 'L' end-of-line

# History search (prefix search like in Bash)
autoload -Uz history-search-end
zle -N history-search-end
bindkey -M vicmd 'k' up-line-or-history
bindkey -M vicmd 'j' down-line-or-history

# Insert mode keybinding: 'jk' to leave insert mode
function vi-insert-exit() {
  zle vi-cmd-mode
}
zle -N vi-insert-exit
# --- Bind "jk" to exit insert mode ---
bindkey -M viins 'jk' vi-insert-exit

# --- Optional: make timeout for multi-key sequences reasonable ---
# Default is 40 (milliseconds) — too short!  Set to ~500ms.
KEYTIMEOUT=10  # 10 * 10ms = 100ms delay window for combos

# Expand tilde (~) automatically when typing paths
setopt EXTENDED_GLOB
setopt AUTO_NAME_DIRS
setopt AUTO_CD

eval "$(direnv hook zsh)"
    '';
  };

  # programs.firefox = lib.mkIf (has_gui && isLinux) {
  programs.firefox = lib.mkIf (has_gui) {
    enable = true;
    profiles.user = {
        extensions = with firefoxAddons; [
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

    extraConfig = {
      core.autocrlf = "input";
      core.fscache = true;
      core.editor = "hx";
      core.pager = "delta";
      core.symlinks = true;

      pull.rebase = false;

      delta.navigate = true;
      delta.line-numbers = true;
      delta.side-by-side = false;

      diff.colorMoved = "default";

      init.defaultbranch = "main";

      interactive.diffFilter = "delta --color-only";
      merge.conflictstyle = "diff3";
    };
  };

  programs.helix = {
    enable = true;
    package = my_helix;
    settings = {
      theme = "solarized_dark";

      editor = {
        bufferline = "multiple";
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
        auto-pairs = false;
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
        end-of-line-diagnostics = "hint";
        inline-diagnostics.cursor-line = "warning";
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

    languages.language = [{
      name = "html";
      file-types = ["html" "htm" "shtml" "xhtml" "xht" "jsp" "asp" "aspx" "jshtm" "volt" "rhtml" "tpl"];
    }];
  };


  programs.i3status-rust = lib.mkIf isLinux {
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
            block = "battery";
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
          /*
          {
            block = "net";
            interval = 10;
            # format = "$icon $ip";
            format = "$icon";
          }
          */
          {
            block = "time";
            interval = 1;
            # format = "$icon $timestamp.datetime(f:'%a %Y/%m/%d %I:%M%p')";
            format = "$icon $timestamp.datetime(f:'%I:%M%p')";
          }
        ];
      };
    };
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user.name = "Cory Duplantis";
      user.email = "cld251@gmail.com";

      # Show only necessary bits for the unique prefix changeset
      template-aliases = {
        "format_short_change_id(id)" = "id.shortest()";
      };

      revset-aliases = {
        "immutable_heads()" = "builtin_immutable_heads() | remote_bookmarks()";
      };
      
      aliases = {
        pull = ["git" "fetch"];
        push = ["git" "push" "--allow-new"];
      };

      # Enable `delta` as the difftool for `jj`

      diff.tool = "delta";
      ui = {
        diff-formatter = ":git";
        pager = ["delta" "--pager" "less -FRX"];
      };
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      username.show_always = true;
      memory_usage.disabled = false;
      time.disabled = false;
    } // lib.optionalAttrs (starship_jj != null) {
      custom.jj = {
        command = "prompt";
        format = "$output";
        ignore_timeout = true;
        use_stdin = false;
        when = true;
        shell = ["starship-jj" "--ignore-working-copy" "starship"];
      };
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
