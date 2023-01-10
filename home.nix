{ config, pkgs, ... }:

# github.com/fmoda3/nix-configs: home/nvim/
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
      grim
      slurp
      pinentry
    ];
  };

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    # no config programs
    pywal.enable = true;
    kitty.enable = true;
    tealdeer.enable = true;
    gpg.enable = true;

    exa = {
      enable = true;
      enableAliases = true;
    };

    fish = {
      enable = true;
    };

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
        signByDefault = true; # TODO
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
        # feline-nvim
        # focus-nvim
        # gitsigns-nvim
        # legendary.nvim
        # nvim-autopairs
        # vim-koka
        comment-nvim
        # coq-artifacts
        # coq_nvim
        dhall-vim
        dressing-nvim
        gruvbox-nvim
        haskell-tools-nvim
        haskell-vim
        indent-blankline-nvim
        leap-nvim
        lsp-status-nvim
        lsp_extensions-nvim
        lspkind-nvim
        nvim-colorizer-lua
        nvim-lspconfig
        nvim-tree-lua
        nvim-treesitter.withAllGrammars
        nvim-treesitter-context
        nvim-treesitter-textobjects
        nvim-ts-rainbow
        nvim-web-devicons
        parinfer-rust
        plenary-nvim
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

  wayland.windowManager.sway = {
    enable = true;
  };

  xdg.configFile.sway = {
    source = ./sway;
    recursive = true;
  };
}
