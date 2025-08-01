{ config, lib, pkgs, username, stateVersion, homeDirectory, nur, system, ... }:

let
  nurNopkgs = import nur { pkgs = pkgs; nurpkgs = pkgs; };
  allowUnfree = config.allowUnfree;
  useWayland = config.useWayland;
  thinkpad = config.thinkpad;
  graphical = config.graphical;
in
{
  nixpkgs.config.allowUnfree = allowUnfree;
  home = {
    stateVersion = stateVersion;
    username = username;
    homeDirectory = homeDirectory;
    packages = with pkgs; [
      ffmpeg
      stow
      dust
      gopass
      gopass-jsonapi
      binwalk
      fastfetch
      fzy
      unzip
      unrar
      rlwrap
      zip
      mosh
      todoist
      wget
      killall
      graphviz
      nix-search
      zellij
      (python3.withPackages (ps: with ps; [
        requests
        pynvim
      ]))
      claude-code
      nodejs_24
    ]
    ++ (if graphical then [
      # pulseaudioFull
      slack
      # webex
      openconnect
      # discord
      nerd-fonts.jetbrains-mono
      font-awesome
      zathura
      caprine-bin
      liberation_ttf
      geogebra
      neovide
      obsidian
    ] ++ (if useWayland then [
      grim
      slurp
      wl-clipboard
      bemenu
    ] else [
    ]) else [ ])
    ++ (if thinkpad then [
      eog
      usbutils
      light
      xclip
      xmlstarlet
      lxappearance
      paprefs
    ] else [ ])
    ++ (if graphical && thinkpad then [ 
        qFlipper
        todoist-electron
        fractal
        libreoffice
        pinentry-gtk2 
        citrix_workspace
        chromium
        pavucontrol
        nemo
        calibre
        zoom
    ] else if graphical then [ 
        pinentry_mac 
    ] else [ pinentry ])
    ;
  };

  xdg.configFile.nvim = {
    source = ./nvim;
    recursive = true;
  };

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    # no config programs
    tealdeer.enable = true; # tldr
    gpg.enable = true;
    fish.enable = true; # shell replacement
    bottom.enable = true; # htop replacement
    ripgrep.enable = true;
    fd.enable = true;
    rclone.enable = true;
    yt-dlp.enable = true;


    # ls replacement
    eza = {
      enable = true;
      enableFishIntegration = true;
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # shell prompt manager
    starship = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        character = {
          success_symbol = "[>>=](bold green)";
          error_symbol = "[_|_](bold red)";
          vicmd_symbol = "[<*>](bold green)";
        };
        python.detect_extensions = [ ];
      };
    };

    # quick shell navigation
    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };

    git = {
      enable = true;
      package = pkgs.gitAndTools.gitFull;
      userName = "Simon Zeng";
      userEmail = "contact@simonzeng.com";
      extraConfig = {
        core.editor = "nvim";
        credential.helper = "store";
      };
      signing = {
        key = "973C9963CA528797";
        signByDefault = true;
      };
    };

    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withPython3 = true;
      defaultEditor = true;

      plugins = with pkgs.vimPlugins; [
        # the goat
        mini-nvim

        # util
        leap-nvim
        vim-repeat

        # git
        git-blame-nvim
        gitsigns-nvim
        neogit

        # appearance
        gruvbox-nvim

        # ide features
        friendly-snippets
        lsp-status-nvim
        lspkind-nvim
        nvim-dap
        nvim-dap-python
        nvim-dap-ui
        nvim-treesitter-context
        nvim-treesitter-endwise
        nvim-treesitter-textobjects
        nvim-treesitter.withAllGrammars
        rainbow-delimiters-nvim
        vista-vim

        # language specific
        dhall-vim
        haskell-tools-nvim
        haskell-vim
        # parinfer-rust
        purescript-vim
        typescript-tools-nvim
        # vim-sexp
        # vim-sexp-mappings-for-regular-people
        vimtex
      ];

      # only loaded when neovim is launched!
      extraPackages = with pkgs; [
        # lsp
        clojure-lsp
        cmake-language-server
        docker-ls
        # dhall-lsp-server
        haskell-language-server
        java-language-server
        kotlin-language-server
        rust-analyzer
        metals
        nil
        nodePackages.bash-language-server
        nodePackages.typescript-language-server
        nodePackages.vscode-langservers-extracted
        nodePackages.yaml-language-server
        ocamlPackages.ocaml-lsp
        pyright
        statix
        lua-language-server
        texlab
        typescript
        ty

        # formatters
        black
        ruff
        nixpkgs-fmt
        ocamlformat
        ocamlPackages.ocamlformat-rpc-lib
      ];
    };
  } // (if graphical then {

    wezterm = {
      enable = true;
      extraConfig = ''
      return {
        font = wezterm.font("JetBrainsMono Nerd Font Mono"),
        font_size = 13.0,
        color_scheme = "GruvboxDark",
        hide_tab_bar_if_only_one_tab = true,
        -- default_prog = { "zsh", "--login", "-c", "tmux attach -t dev || tmux new -s dev" },
        -- keys = {
        --   {key="n", mods="SHIFT|CTRL", action="ToggleFullScreen"},
        -- }
      }
      '';
    };

  } else { });
} // (if graphical && thinkpad then {
  services.mako.enable = useWayland; # wayland notification daemon
  mpv.enable = true; # media player
  firefox =
    {
      enable = true;
      package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
        extraPolicies = {
          ExtensionSettings = { };
        };
      };
      profiles.default = {
        id = 0;
        name = "Default";
        isDefault = true;
        extensions = with nurNopkgs.repos.rycee.firefox-addons; [
          ublock-origin
          vimium
          gopass-bridge
          addy_io
          darkreader
        ];
        settings = {
          "browser.theme.content-theme" = 0; # dark theme
          "browser.theme.toolbar-theme" = 0; # dark theme
          "findbar.modalHighlight" = true; # dims screen and animates during ctrl-f
          "findbar.highlightAll" = true; # highlights all ctrl-f results
          "browser.newtabpage.activity-stream.enabled" = false; # better new tab
          "extensions.pocket.enabled" = false; # disable pocket
          "browser.compactmode.show" = true;
          "identity.fxaccounts.enabled" = false;
        };
      };
    };
  i3status = {
    enable = true;
    enableDefault = false;
    general = {
      interval = 1;
      colors = true;
      color_good = "#b8bb26";
      color_bad = "#fb4934";
      color_degraded = "#fabd2f";
    };
    modules = {
      "volume master" = {
        position = 1;
        settings = {
          format = "%volume  ";
          format_muted = " ";
          device = "default";
          mixer = "Master";
          mixer_idx = 0;
        };
      };
      "wireless wlp2s0" = {
        position = 2;
        settings = {
          format_up = "%quality  %essid %ip";
          format_down = "";
        };
      };
      "battery 0" = {
        position = 3;
        settings = {
          format = "%status %percentage %consumption %remaining";
          format_down = "";
          last_full_capacity = true;
          integer_battery_capacity = true;
          low_threshold = 11;
          threshold_type = "percentage";
          hide_seconds = true;
          status_chr = " ";
          status_bat = " ";
          status_unk = " ";
          status_full = " ";
        };
      };
      "tztime local" = {
        position = 4;
        settings = {
          format = " %I:%M %p";
        };
      };
    };
  };
} else { })
  // (if graphical && useWayland then {

  wayland.windowManager.sway =
    {
      enable = true;
      wrapperFeatures.gtk = true;
      config = {
        modifier = "Mod4";
        gaps = {
          inner = 10;
          outer = 0;
          smartGaps = true;
        };
        input =
          if thinkpad then {
            "2:10:TPPS/2_Elan_TrackPoint".tap = "enabled";
            "1739:0:Synaptics_TM3289-021".tap = "enabled";
          } else { };
        terminal = "kitty";
        output = {
          "*" = {
            bg = "~/.config/nixpkgs/backgrounds/cozywindow.jpg fill";
          };
        };
      };
    };
} else if thinkpad && graphical && !useWayland then {
  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps; # TODO: remove when merger hits
    config = {
      terminal = "kitty";
      modifier = "Mod4";
      window.hideEdgeBorders = "smart";
      workspaceAutoBackAndForth = true;
      gaps = {
        inner = 10;
        outer = 0;
        smartGaps = true;
      };
      window.commands = [{ criteria = { title = "HearthstoneOverlay"; }; command = "sticky enable"; }];
    };
  };
} else { }) 
  // (if thinkpad then {
    services.gpg-agent = {
      enable = true;
      pinentryFlavor = if graphical then "gtk2" else "tty";
      enableFishIntegration = true;
    };
  }
else { })


