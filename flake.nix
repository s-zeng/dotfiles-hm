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
      localPath = ./local.nix;
      pwd = builtins.getEnv "PWD";
      impureLocalPath = "${pwd}/local.nix";
      local = if builtins.pathExists localPath then import localPath else if pwd != "" && builtins.pathExists impureLocalPath then import impureLocalPath else throw ''
        Missing local configuration at ./local.nix.
        Create ./local.nix with:
        {
          username = "your-username";
          name = "Your Name";
          email = "you@example.com";
          system = "aarch64-darwin";
          config = {
            useWayland = false;
            thinkpad = false;
            graphical = true;
            allowUnfree = true;
          };
        }

        Note: if `local.nix` is gitignored, flake evaluation will not see it unless run with `--impure`.
      '';

      username = if builtins.isString (local.username or null) then local.username else throw "Invalid ./local.nix: `username` must be a string.";
      name = if builtins.isString (local.name or null) then local.name else throw "Invalid ./local.nix: `name` must be a string.";
      email = if builtins.isString (local.email or null) then local.email else throw "Invalid ./local.nix: `email` must be a string.";
      system = if builtins.isString (local.system or null) then local.system else throw "Invalid ./local.nix: `system` must be a string.";
      config = if builtins.isAttrs (local.config or null) then local.config else throw "Invalid ./local.nix: `config` must be an attribute set.";
      _validateAllowUnfree = if builtins.isBool (config.allowUnfree or null) then null else throw "Invalid ./local.nix: `config.allowUnfree` must be a bool.";
      _validateUseWayland = if builtins.isBool (config.useWayland or null) then null else throw "Invalid ./local.nix: `config.useWayland` must be a bool.";
      _validateThinkpad = if builtins.isBool (config.thinkpad or null) then null else throw "Invalid ./local.nix: `config.thinkpad` must be a bool.";
      _validateGraphical = if builtins.isBool (config.graphical or null) then null else throw "Invalid ./local.nix: `config.graphical` must be a bool.";

      stateVersion = "25.05";     # See https://nixos.org/manual/nixpkgs/stable for most recent

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
        inherit homeDirectory config lib pkgs system username name email stateVersion nur pkgs-stable codex-cli-nix;
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
