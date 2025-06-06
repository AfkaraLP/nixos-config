{ config, lib, pkgs, ... }:

{
  # imports =
    # [ ./nixvim_options/keymaps.nix ./nixvim_options/plugins.nix ]; # imports

  programs = {

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

    # nixvim = {
    #   enable = true;
    #   enableMan = true;
    #   viAlias = true;
    #   vimAlias = true;
    #   clipboard.register = "unnamedplus";
    #   colorschemes.tokyonight = {
    #     enable = true;
    #     settings.transparent = true;
    #   }; # colorschemes.tokyonight
    #   dependencies = { rust-analyzer.enable = true; }; # dependencies
    # }; # nixvim

    git.enable = true;

    # neovim = {
    #   enable = true;
    #   vimAlias = true;
    #   viAlias = true;
    #   defaultEditor = true;
    # }; # neovim 

    yazi = { enable = true; }; # yazi

  }; # programs

}

