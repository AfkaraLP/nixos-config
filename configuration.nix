# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.

  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.xkb = {
    layout = "us";
    variant = "workman";
  };

  users.users.afkara = {
    isNormalUser = true;
    description = "afkara";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  services = { 
    getty.autologinUser = "afkara"; 
    pipewire.wireplumber = {
      enable = true;
    };
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    wezterm
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment = {
    variables = {
      NIXOS_OZONE_WL = "1";
      # GBM_BACKEND = "nvidia-drm";
      # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      # XDG_SESSIONS_TYPE = "wayland";
    };
  };

  # xdg.portal = {
    # enable = true;
    # wlr.enable = true;
    # xdgOpenUsePortal = true;
    # extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  # };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware = {
    nvidia = { 
      open = true;
      modesetting.enable = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;
    };
    
    graphics = {
      enable = true;
      extraPackages = with pkgs; [ nvidia-vaapi-driver ];
    };

    pulseaudio.support32Bit = true;
  };
}
