# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  config = import ./config.nix;
in
{
  imports =
    [
      # Include the results of the hardware scan.
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
  # time.timeZone = "America/Toronto";
  services.automatic-timezoned.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  services.dbus.enable = true;
  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kronicmage = {
    description = "Simon Zeng";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "dialout" ];
    isNormalUser = true;
    packages = with pkgs; [ ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCpeorNX0ypRXlfZR3k36wjB3LfVUSqBXXyI7nGkv8K8ow5lLIfruzT67YYBE4nQqpKpcQ/cPZM6iXm8bU1UJnQsodcGIeyiime56KlRypgiYg7P+3jyiaDfkWFeY7ddWRGwNkLcwouYVowMC387D9tfMczJPPM6N1ywGJ5aR/G3tF1RoeLxe0UC8FULEJrUFESeXXkCKm45CZqarfsPQHd7cq9XLNlyZeRqXFMx1KxnRnJpW/46FActJPDANZPvppLfvlk209HNIG0iuJzyhbaxDW7/mhHPvNw4VQexFfdkKn6uUWhoxPgUwL709+qwYDXlKJgzcdFJoNeTOdEL6xj kronicmage@SimonThinkpad"
    ];
  };
  programs.fish.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nixVersions.stable;

    settings.substituters = [
      "https://cache.nixos.org"
      "https://cache.dhall-lang.org"
      "https://dhall.cachix.org"
    ];

    settings.trusted-public-keys = [
      "cache.dhall-lang.org:I9/H18WHd60olG5GsIjolp7CtepSgJmM2CsO813VTmM="
      "dhall.cachix.org-1:8laGciue2JBwD49ICFtg+cIF8ddDaW7OFBjDb/dHEAo="
    ];

    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget

  environment.systemPackages = with pkgs; [
    webex
    # wget
    # (python3.withPackages (ps: with ps; [
    #   requests
    # ]))
    # killall
    # lxappearance
  ];

  # List services that you want to enable:
  # services.tlp =
  #   if config.thinkpad then {
  #     enable = true;
  #   } else { };

  # Enable the OpenSSH daemon.
  services.openssh =
    if !config.thinkpad then {
      enable = true;
      passwordAuthentication = false;
      kbdInteractiveAuthentication = false;
    } else { };
  services.pcscd.enable = true;

  services.printing = {
    enable = true;
    drivers = [ pkgs.samsung-unified-linux-driver ];
  };

  programs.dconf.enable = true;
  programs.steam =
    if config.graphical then {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    } else { };
  services.xserver = {
    xkb = {
        layout = "us";
        variant = "";
    };
    enable = true;
  } // (if config.thinkpad then { } else { videoDrivers = [ "nvidia" ]; });
  services.displayManager = {
    sddm.wayland.enable = true;
    defaultSession = "plasma";
  };
  services.desktopManager.plasma6.enable = true;
  services.libinput.enable = true;
  hardware.graphics.enable = true;
  hardware.bluetooth.enable = true;
  # services.pulseaudio.enable = true;
  # services.pulseaudio.support32Bit = true;
  services.blueman.enable = true;

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
      wlr.enable = config.useWayland;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ] ++ (if config.useWayland then [
        xdg-desktop-portal-wlr
      ] else [ ]);
    };
  };

  security.pam.services.swaylock = {
    text = "auth include login";
  };
  security.polkit.enable = true;
  security.rtkit.enable = true;

}
