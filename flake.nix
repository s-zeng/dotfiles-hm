{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
  };

  outputs = { self, nixpkgs, home-manager, nur }:
    let
      # Values you should modify
      username = "kronicmage"; # $USER
      system = "x86_64-linux";  # x86_64-linux, aarch64-multiplatform, etc.
      stateVersion = "22.11";     # See https://nixos.org/manual/nixpkgs/stable for most recent

      config =
        # mega ugly copy paste of system/config.nix cause idk how to import this
        {
          useWayland = false;
          thinkpad = true;
          graphical = true;
          allowUnfree = true;
        };

      pkgs = import nixpkgs {
        inherit system;

        config = {
          allowUnfree = config.allowUnfree;
          permittedInsecurePackages = [
            "electron-21.4.0"
          ];
        };
      };

      homeDirPrefix = if pkgs.stdenv.hostPlatform.isDarwin then "/Users" else "/home";
      homeDirectory = "/${homeDirPrefix}/${username}";

      home = (import ./home.nix {
        inherit homeDirectory config pkgs system username stateVersion nur;
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
