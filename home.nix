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
    ]
    ++ (if graphical then [
      unstable.discord
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
      pavucontrol
    ] else [ ])
    ++ (if useWayland && graphical then with pkgs; [
      grim
      slurp
      wl-clipboard
    ] else if graphical && !useWayland then [
      xclip
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
        };
      };
    kitty = {
      enable = true;
      font.name = "JetBrainsMono Nerd Font";
      font.size = 16;
      theme = "Gruvbox Dark";
    };
  } else { });
} // (if graphical && useWayland then {

  wayland.windowManager.sway =
    {
      enable = true;
      wrapperFeatures.gtk = true;
      config = {
        bars = [
          {
            position = "top";
            # TODO: port my i3status stuff here
          }
        ];
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
        menu = "rofi -show run";
        terminal = "kitty";
        # extraConfigEarly = [ "include \"$HOME/.cache/wal/colors-sway\"" ]; # TODO: recently added, check for updates
        # output = {
        #   "*" = {
        #     bg = "~/path/to/background.png fill";
        #   };
        # };
        # keybindings =
        #   let
        #     modifier = config.wayland.windowManager.sway.config.modifier;
        #   in
        #   lib.mkOptionDefault {
        #     "${modifier}+Return" = "exec ${pkgs.foot}/bin/foot";
        #     "${modifier}+Shift+q" = "kill";
        #     "${modifier}+d" = "exec ${pkgs.dmenu}/bin/dmenu_path | ${pkgs.dmenu}/bin/dmenu | ${pkgs.findutils}/bin/xargs swaymsg exec --";
        #   };
      };
    };
} else if graphical && !useWayland then {
  services.random-background = {
    enable = true;
    imageDirectory = "%h/.config/nixpkgs/backgrounds";
  };
  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps; # TODO: remove when merger hits
    config = {
      terminal = "kitty";
      modifier = "Mod4";
      gaps = {
        inner = 10;
        outer = 0;
        smartGaps = true;
      };
    };
  };
} else { })
