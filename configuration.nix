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

  networking = {
    hostName = "nixos"; # Define your hostname.
    networkmanager.enable = true;
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
	  command = "Hyprland";
	}; # default_session 
      }; # settings 
    }; # greetd 

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    }; # pipewire

  }; # services

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.11"; # Did you read the comment?
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment = {
    systemPackages = with pkgs; [
      wezterm
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

    pulseaudio.support32Bit = true;
  }; # hardware 
}
