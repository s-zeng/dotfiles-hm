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
  };

  outputs = { self, nixpkgs, home-manager, nur, claude-code, nixpkgs-stable, ... }:
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
        overlays = [ claude-code.overlays.default ];
      };

      pkgs-stable = import nixpkgs-stable {
        inherit system;
      };

      lib = home-manager.lib;

      homeDirPrefix = if pkgs.stdenv.hostPlatform.isDarwin then "/Users" else "/home";
      homeDirectory = "/${homeDirPrefix}/${username}";

      home = (import ./home.nix {
        inherit homeDirectory config lib pkgs system username stateVersion nur pkgs-stable;
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
