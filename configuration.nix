# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let 
  config = import ./config.nix;
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "nixos"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # Configure keymap in X11
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  services.dbus.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kronicmage = {
    description = "Simon Zeng";
    extraGroups = [ "networkmanager" "wheel" "video" ];
    isNormalUser = true;
    packages = with pkgs; [];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCpeorNX0ypRXlfZR3k36wjB3LfVUSqBXXyI7nGkv8K8ow5lLIfruzT67YYBE4nQqpKpcQ/cPZM6iXm8bU1UJnQsodcGIeyiime56KlRypgiYg7P+3jyiaDfkWFeY7ddWRGwNkLcwouYVowMC387D9tfMczJPPM6N1ywGJ5aR/G3tF1RoeLxe0UC8FULEJrUFESeXXkCKm45CZqarfsPQHd7cq9XLNlyZeRqXFMx1KxnRnJpW/46FActJPDANZPvppLfvlk209HNIG0iuJzyhbaxDW7/mhHPvNw4VQexFfdkKn6uUWhoxPgUwL709+qwYDXlKJgzcdFJoNeTOdEL6xj kronicmage@SimonThinkpad"
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget

  environment.systemPackages = with pkgs; [
    wget
    (python3.withPackages(ps: with ps; [ 
      requests 
    ]))
    killall
    lxappearance
  ];

  # List services that you want to enable:
  services.tlp = if config.thinkpad then {
    enable = true;
  } else {};

  # Enable the OpenSSH daemon.
  services.openssh = if !config.thinkpad then {
    enable = true;
    passwordAuthentication = false;
    kbdInteractiveAuthentication = false;
  } else {};
  services.pcscd.enable = true;

  programs.dconf.enable = true;
  services.xserver = {
    layout = "us";
    xkbVariant = "";
    enable = true;
    libinput.enable = true;
    displayManager.lightdm.enable = true;
    windowManager.i3.enable = true;
    windowManager.i3.package = pkgs.i3-gaps;
    displayManager.defaultSession = "none+i3";
  } // (if config.thinkpad then {} else {videoDrivers = ["nvidia"];});
  hardware.opengl.enable = true;
  hardware.video.hidpi.enable = !config.thinkpad;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];
    };
  };

  security.pam.services.swaylock = {
    text = "auth include login";
  };

}
