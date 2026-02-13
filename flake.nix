{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
    claude-code.url = "github:sadjow/claude-code-nix";
    nixpkgs-stable.url = "nixpkgs/nixos-24.11"; # workaround for gitui 20251101
    copyparty.url = "github:9001/copyparty";
    codex-cli-nix.url = "github:sadjow/codex-cli-nix";
    nvim-treesitter-main.url = "github:iofq/nvim-treesitter-main";
  };

  outputs = { self, nixpkgs, home-manager, nur, claude-code, codex-cli-nix, nixpkgs-stable, copyparty, nvim-treesitter-main, ... }:
    let
      # Values you should modify
      username = "simonzeng"; # $USER
      system = "aarch64-darwin";  # x86_64-linux, aarch64-multiplatform, etc.
      stateVersion = "25.05";     # See https://nixos.org/manual/nixpkgs/stable for most recent

      config =
        # mega ugly copy paste of system/config.nix cause idk how to import this
        {
          useWayland = false;
          thinkpad = false;
          graphical = true;
          allowUnfree = true;
        };

      pkgs = import nixpkgs {
        inherit system;

        config = {
          allowUnfree = config.allowUnfree;
        };
        overlays = [
          claude-code.overlays.default
          copyparty.overlays.default
          nvim-treesitter-main.overlays.default
          (f: p: {
            vimPlugins = p.vimPlugins.extend (vf: vp: {
              nvim-treesitter = vp.nvim-treesitter.withAllGrammars;

              nvim-treesitter-context = vp.nvim-treesitter-context.overrideAttrs (old: {
                dependencies = (old.dependencies or [ ]) ++ [ vf.nvim-treesitter ];
              });
              nvim-treesitter-endwise = vp.nvim-treesitter-endwise.overrideAttrs (old: {
                dependencies = (old.dependencies or [ ]) ++ [ vf.nvim-treesitter ];
              });
              nvim-treesitter-textobjects = vp.nvim-treesitter-textobjects.overrideAttrs (old: {
                dependencies = (old.dependencies or [ ]) ++ [ vf.nvim-treesitter ];
              });
            });
          })
        ];
      };

      pkgs-stable = import nixpkgs-stable {
        inherit system;
      };

      lib = home-manager.lib;

      homeDirPrefix = if pkgs.stdenv.hostPlatform.isDarwin then "/Users" else "/home";
      homeDirectory = "/${homeDirPrefix}/${username}";

      home = (import ./home.nix {
        inherit homeDirectory config lib pkgs system username stateVersion nur pkgs-stable codex-cli-nix;
      });
    in
    {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          home
        ];
      };
    };
}
