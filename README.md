# dotfiles-hm

Dotfiles, managed by [Home 
Manager](https://github.com/nix-community/home-manager).

Produces largely the same config as my [old dotfiles 
repo](https://github.com/s-zeng/dotfiles)

## Installation

1. Install home manager
2. Clone this repo to `~/.config/nixpkgs/`
3. Create `local.nix` in repo root:
   ```nix
   {
     username = "your-username";
     system = "aarch64-darwin"; # or "x86_64-linux"
     config = {
       useWayland = false;
       thinkpad = false;
       graphical = true;
       allowUnfree = true;
     };
   }
   ```
4. Run `home-manager switch`
