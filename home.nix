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
    ];
  };


  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # no config programs
  programs.pywal.enable = true;
  programs.kitty.enable = true;

  programs.git = {
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
      signByDefault = false; # TODO
    };

  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withPython3 = true;
    defaultEditor = true;

    plugins = with pkgs.vimPlugins; [
      # feline-nvim
      # focus-nvim
      # gitsigns-nvim
      # legendary.nvim
      # nvim-autopairs
      # telescope-ui-select-nvim
      # vim-koka
      # (nvim-treesitter.withPlugins
      #   (plugins: pkgs.nvim-ts-grammars.allGrammars)
      # )
      comment-nvim
      coq-artifacts
      coq_nvim
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
      nvim-treesitter
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
