{ config, pkgs, ... }:

# github.com/fmoda3/nix-configs: home/nvim/
let
  nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") { inherit pkgs; };
in
{
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
      # grim
      # slurp
      flameshot # TODO: added to programs.flameshot recently, check for update 
      pinentry
      gopass
      gopass-jsonapi
      binwalk
    ];

    # TODO: programs.neovim.defaultEditor merged end of 2022, check for updates
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    # no config programs
    pywal.enable = true; # color manager
    kitty.enable = true; # terminal emulator
    tealdeer.enable = true; # tldr
    gpg.enable = true;
    fish.enable = true; # shell replacement
    bottom.enable = true; # htop replacement
    mpv.enable = true; # media player

    # ls replacement
    exa = {
      enable = true;
      enableAliases = true;
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
        python.detect_extensions = [];
      };
    };

    # quick shell navigation
    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };

    firefox = {
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

      extraPackages = with pkgs; [
        ripgrep
        fd
        fzy

        nodePackages.bash-language-server
        haskellPackages.haskell-language-server
        haskellPackages.dhall-lsp-server
        java-language-server
        kotlin-language-server
        sumneko-lua-language-server
        rnix-lsp
        nixpkgs-fmt
        statix
        pyright
        black
        nodePackages.typescript-language-server
        nodePackages.vscode-langservers-extracted
      ];
    };

  };

  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "tty";
    enableFishIntegration = true;
  };


  xdg.configFile.nvim = {
    source = ./nvim;
    recursive = true;
  };
}
