# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot = {
    loader = {
      systemd-boot.configurationLimit = 3;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    }; # loader 

    initrd = {
      compressor = "zstd";
      availableKernelModules = [ "nvme" "ext4" ];
    }; # initrd 
  }; # boot 

  ### BOOT
  systemd.services = {
    systemd-udev-settle.enable = false; # if all shit fails enable that again
    NetworkManager-wait-online.enable = false;
    "systemd-timesyncd".enable = false;
    nscd.serviceConfig.TimeoutStopSec = "3s";
    "NetworkManager-wait-online".serviceConfig.TimeoutStopSec = "5s";
    nscd.enable = false;
    # "systemd-timesyncd".wantedBy = lib.mkForce [ ];
  }; # systemd.services 
  services = {
    ntp.enable = false;
    chrony.enable = true;

    # journald.settings = {
    #   Storage = "volatile";
    #   SystemMaxUse = "50M";
    #   RuntimeMaxUse = "20M";
    #   MaxRetentionSec = "1week";
    # }; # journald.settings 
  }; # services 
  systemd.extraConfig = ''
    DefaultTimeoutStopSec=10s
  '';
  ### BOOT

  networking = {
    hostName = "nixos"; # Define your hostname.
    networkmanager.enable = true;
    dhcpcd.wait = "background";
  }; # networking 

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";

  users.users.afkara = {
    isNormalUser = true;
    description = "afkara";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  }; # users.users.afkara 


  services = { 
    xserver = { 
      xkb = {
        layout = "us";
        variant = "workman";
      }; # xkb

      videoDrivers = [ "nvidia" ];
    }; # xserver
     
    getty.autologinUser = "afkara"; 
    greetd = {
      enable = true;
      settings = {
        default_session = {
	  command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
	  user = "greeter";
	}; # default_session 
      }; # settings 
    }; # greetd 

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    }; # pipewire

    pulseaudio.support32Bit = true;
  }; # services

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.11"; # Did you read the comment?
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment = {
    systemPackages = with pkgs; [
      killall
    ]; # systemPackages 
    variables = {
      NIXOS_OZONE_WL = "1";
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    }; # variables 
  }; # environment 

  hardware = {
    nvidia = {
      open = true;
      modesetting.enable = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;
    }; # nvidia
        
    graphics = {
      enable = true;
      extraPackages = with pkgs; [ nvidia-vaapi-driver ];
    }; # graphics 

  }; # hardware 

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    configPackages = [ pkgs.hyprland ];
  }; # xdg.portal 

  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 3d";
} # END
