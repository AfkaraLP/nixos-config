{ config, lib, pkgs, ... }: 

{
  imports = [
    ./nixvim_options/keymaps.nix
    ./nixvim_options/plugins.nix
  ]; # imports 

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

    nixvim = {
      enable = true;
      enableMan = true;
      viAlias = true;
      vimAlias = true;
      clipboard.providers.wl-copy.enable = true;
      colorschemes.tokyonight = {
        enable = true;
	settings.transparent = true;
      }; # colorschemes.tokyonight 
      plugins = {
        lazy.enable = true;
	telescope.enable = true;
	lualine.enable = true;
	snacks.enable = true;
	fzf-lua.enable = true;
	which-key.enable = true;
	mini = {
	  enable = true;
	  # mockDevIcons = true;
	}; # mini 
	oil.enable = true;
	blink-cmp.enable = true;
	lazydev.enable = true;
	bufferline.enable = true;
	noice.enable = true;
	trouble.enable = true;
	conform-nvim.enable = true;

	lsp = {
	  enable = true;

	  servers = {
	    rust_analyzer = {
	      enable = true;
	    };
	    nixd.enable = true;
	    jsonls.enable = true;
	    tailwindcss.enable = true;
	    html.enable = true;
	    jedi_language_server.enable = true;
	    yamlls.enable = true;
	    quick_lint_js.enable = true;
	    bashls.enable = true;
	  }; # servers 
	}; # lsp 
      }; # plugins 
      dependencies = {
        rust-analyzer.enable = true;
      }; # dependencies 
    }; # nixvim 
  
    git.enable = true;
  
    # neovim = {
    #   enable = true;
    #   vimAlias = true;
    #   viAlias = true;
    #   defaultEditor = true;
    # }; # neovim 

    yazi = {
      enable = true;
    }; # yazi 

  }; # programs 

}

