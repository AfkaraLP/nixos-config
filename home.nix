{ config, pkgs, lib,... }:
let
  wallpaperConfig = {
    default = {
      path = "/home/afkara/wallpapers";
      duration = "10m";
      sorting = "random";
    };
  };
in
{
  home.username = "afkara";
  home.homeDirectory = "/home/afkara";

  imports = [
    ./home-modules/hyprland.nix
  ];

  home.packages = with pkgs; [
    vesktop
    bat
  ]; # home.packages 

  xdg.configFile."wpaperd/wallpaper.toml".source = (pkgs.formats.toml { }).generate "wallpaper_config_afkara" wallpaperConfig;

  services = {
    wpaperd = {
      enable = true;
      settings = {};
    };
  };
  
  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = (_: true);
  }; # nixpkgs.config 

  home.stateVersion = "24.11";

  programs = {
    home-manager.enable = true;

    zsh = {
    enable = true;
      oh-my-zsh = {
        enable = true;
	plugins = [ "git" ];
	theme = "agnoster";
      }; # oh-my-zsh 
    }; # zsh 

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    }; # zoxide 

    wezterm = {
      enable = true;
      enableZshIntegration = true;
      extraConfig = ''
        local config = wezterm.config_builder()
	config.default_prog = { "zsh" }
        
        config.font_size = 12.0
	config.hide_tab_bar_if_only_one_tab = true
	config.window_background_opacity = 0.5
	config.window_close_confirmation = "NeverPrompt"
	config.window_padding = {
	  left = 2, 
	  top = 2, 
	  bottom = 2, 
	  right = 2,
	} 
	config.window_decorations = "RESIZE"
	config.window_frame = { inactive_titlebar_bg = "#000000", }

	return config
      '';
      
    }; # wezterm 
  }; # programs 
}
