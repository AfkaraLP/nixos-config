{ lib, pkgs, ... }: 

{
  programs = {
  
    firefox = {
      enable = true; 
      package = (pkgs.wrapFirefox.override { libpulseaudio = pkgs.libpressureaudio; }) pkgs.firefox-unwrapped { };
      preferences = {
        # "widget.use-xdg-desktop-portal.file-picker" = 1;
      }; # preferences 
      policies = {
        PromptForDownloadLocation = "enabled";
	Cookies = {
	  Allow = [];
	  AllowSessions = [];
	  Block = [];
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
  
    neovim = {
      enable = true;
      vimAlias = true;
      viAlias = true;
      defaultEditor = true;
    }; # neovim 

    yazi = {
      enable = true;
    }; # yazi 

  }; # programs 

}

