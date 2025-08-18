# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./.hidden/hardware-configuration.nix
      ./.hidden/systemd_services.nix
  	  ./default_programs.nix
    ];

  networking = {
    hostName = "nixos"; # Define your hostname.
    networkmanager.enable = true;
    dhcpcd.wait = "background";
  }; # networking 

  time.timeZone = "Europe/Berlin";

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
      extraConfig.pipewire = {
        "context.properties" = {
          "default.clock.allowed-rates" = [ 44100 48000 96000 ];
          "default.clock.quantum" = 2048;
          "default.clock.min-quantum" = 2048;
          "default.clock.max-quantum" = 8192;
        };
      };
    }; # pipewire

    pulseaudio.support32Bit = true;
  }; # services

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.05"; # Did you read the comment?
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment = {
    systemPackages = with pkgs; [
      lunar-client
      wtype
      killall
      nixd
      nixfmt-classic
      dconf
      sway-contrib.grimshot
      wl-clipboard
      easyeffects
      typst
      tinymist
      vesktop
      wineWowPackages.waylandFull
      winetricks
      wineasio
      (prismlauncher.override {
        jdks = [
          temurin-bin-21
          temurin-bin-17
          temurin-bin-8
        ];
        additionalPrograms = [ ffmpeg ];
        additionalLibs = [ pkgs.glfw-wayland ];
      })
      mangohud
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
      nvidiaSettings = true;
    }; # nvidia
        
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [ nvidia-vaapi-driver ];
    }; # graphics 

    bluetooth = {
    enable = true;
    settings = {
      General = {
        Name = "Hello";
        ControllerMode = "dual";
        FastConnectable = "true";
        Experimental = "true";
      }; # General 
      Policy = {
        AutoEnable = "true";
      }; # Policy 
    }; # settings 
    }; # bluetooth 

  }; # hardware 

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    configPackages = [ pkgs.hyprland ];
  }; # xdg.portal 
} # END
