{ config, lib, pkgs, ... }:

{
  programs = {
    gamemode.enable = true;
    gamescope = {
      enable = true;
      capSysNice = true;
    };

    hyprland = {
      enable = true;
      xwayland.enable = true;
    };


    regreet = {
      enable = true;
      settings = {
        commands = { reboot = [ "systemctl" "reboot" ]; };
        # background = {
        #   path = ../../home/afkara/wallpapers/3354994-jacato-deggy-hybrid-mammal.jpg;
        # };
      };
    };

    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    firefox = {
      enable = true;
      package =
        (pkgs.wrapFirefox.override { libpulseaudio = pkgs.libpressureaudio; })
        pkgs.firefox-unwrapped { };
      preferences = {
        # "widget.use-xdg-desktop-portal.file-picker" = 1;
      }; # preferences
      policies = {
        PromptForDownloadLocation = "enabled";
        Cookies = {
          Allow = [ ];
          AllowSessions = [ ];
          Block = [ ];
          Behavior = "reject-tracker-and-partition-foreign";
        }; # Cookies
        DisablePocket = true;
        DisableTelemetry = true;
        DisableSetDesktopBackground = true;
        EnableTrackingProtection = {
          # Value = true;
          Cryptomining = true;
          # Fingerprinting = true;
          # EmailTracking = true;
        }; # EnableTrackingProtection
        TranslateEnabled = false;
        DontCheckDefaultBrowser = true;
        SkipTermsOfUse = true;
      }; # policies
    }; # firefox

    git.enable = true;

    yazi = { enable = true; }; # yazi

  }; # programs

}

