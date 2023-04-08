{ config, pkgs, ... }:

# github.com/fmoda3/nix-configs: home/nvim/
let
  nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") { inherit pkgs; };
  unstable = import <nixpkgs-unstable> { config.allowUnfree = true; };
  config = import ./config.nix;
  useWayland = config.useWayland;
  thinkpad = config.thinkpad;
  graphical = config.graphical;
in
{
  nixpkgs.config.allowUnfree = true;
  home = {
    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    username = "kronicmage";
    homeDirectory = "/home/kronicmage";

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "22.11";

    packages = with pkgs; [
      pinentry
      gopass
      gopass-jsonapi
      binwalk
      neofetch
      ripgrep
      fd
      fzy
      unzip
      unrar
      rlwrap
      zip
      mosh
      todoist
    ]
    ++ (if graphical then [
      unstable.discord
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
      pavucontrol
      font-awesome
      zathura
      chromium
      libreoffice
      caprine-bin
      gnome.eog
      todoist-electron
    ] ++ (if useWayland then [
      grim
      slurp
      wl-clipboard
      bemenu
    ] else [
      xclip
    ]) else [ ])
    ++ (if thinkpad then [
      light
    ] else [ ])
    ;


    # TODO: programs.neovim.defaultEditor merged end of 2022, check for updates
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  services.gpg-agent = {
    enable = true;
    pinentryFlavor = if graphical then "gtk2" else "tty";
    enableFishIntegration = true;
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

    # ls replacement
    exa = {
      enable = true;
      enableAliases = true;
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
      # defaultEditor = true; # TODO: merged end of 2022, check for updates

      plugins = with pkgs.vimPlugins; [
        # focus-nvim
        comment-nvim
        coq-artifacts
        coq_nvim
        dhall-vim
        dressing-nvim
        gitsigns-nvim
        gruvbox-nvim
        haskell-tools-nvim
        haskell-vim
        indent-blankline-nvim
        leap-nvim
        lsp-status-nvim
        lsp_extensions-nvim
        lspkind-nvim
        nvim-autopairs
        nvim-colorizer-lua
        nvim-lspconfig
        nvim-tree-lua
        nvim-treesitter-context
        nvim-treesitter-textobjects
        nvim-treesitter.withAllGrammars
        nvim-ts-rainbow
        nvim-web-devicons
        parinfer-rust
        purescript-vim
        stabilize-nvim
        telescope-fzy-native-nvim
        telescope-nvim
        telescope-symbols-nvim
        telescope-ui-select-nvim
        vim-endwise
        vim-repeat
        vim-sexp
        vim-sexp-mappings-for-regular-people
        vim-surround
        vimagit
        vimtex
        vista-vim
        which-key-nvim
      ];

      # only loaded when neovim is launched!
      extraPackages = with pkgs; [
        # lsp
        clojure-lsp
        cmake-language-server
        docker-ls
        haskellPackages.dhall-lsp-server
        haskellPackages.haskell-language-server
        java-language-server
        kotlin-language-server
        metals
        nodePackages.bash-language-server
        nodePackages.typescript-language-server
        nodePackages.vscode-langservers-extracted
        nodePackages.yaml-language-server
        ocamlPackages.ocaml-lsp
        pyright
        rnix-lsp
        rust-analyzer
        statix
        sumneko-lua-language-server
        texlab

        # formatters
        black
        nixpkgs-fmt
        ocamlformat
        ocamlPackages.ocamlformat-rpc-lib
      ];
    };
  } // (if graphical then {

    mpv.enable = true; # media player
    mako.enable = useWayland; # wayland notification daemon
    firefox =
      {
        enable = true;
        package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
          extraPolicies = {
            ExtensionSettings = { };
          };
        };
        extensions = with nur.repos.rycee.firefox-addons; [
          ublock-origin
          vimium
          gopass-bridge
          anonaddy
          darkreader
        ];
        profiles.default = {
          id = 0;
          name = "Default";
          isDefault = true;
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
    kitty = {
      enable = true;
      font.name = "JetBrainsMono Nerd Font";
      font.size = if thinkpad then 13 else 16;
      theme = "Gruvbox Dark";
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
  } else { });
} // (if graphical then {
  services.random-background = {
    enable = true;
    imageDirectory = "%h/.config/nixpkgs/backgrounds";
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
} else if graphical && !useWayland then {
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
    };
  };
} else { })
