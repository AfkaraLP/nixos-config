{ config, pkgs, lib,... }:

{
  home.username = "afkara";
  home.homeDirectory = "/home/afkara";

  home.packages = with pkgs; [
    vesktop
    bat
  ];
  
  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      "$mod" = "SUPER";
      "$browser" = "firefox";
      "$terminal" = "wezterm";
      "$discord" = "vesktop";
      "$filemanager" = "yazi";

      input = {
        kb_layout = "us";
	kb_variant = "workman";
	follow_mouse = 1;
	sensitivity = 0;
      }; # input 

      bind = [
        "$mod, Q, killactive"
        "$mod, F, exec, $browser"
	"$mod, T, exec, $terminal"
	"$mod, M, exit,"
        "$mod, E, exec, $fileManager"
        "$mod, V, togglefloating,"
        "$mod, R, exec, $menu"
        "$mod, P, pseudo, # dwindle"
        "$mod, S, togglesplit, # dwindle"
        "$mod, D, exec, $discord"

        "$mod, H, movefocus, l"
	"$mod, L, movefocus, r"
	"$mod, J, movefocus, d"
	"$mod, K, movefocus, u"

      ]; # bind 

      bindm = [
	"$mod, mouse:272, movewindow"
	"$mod, mouse:273, resizewindow"
      ]; # bindm 

      exec-once = "$terminal & $browser & $discord";

      monitor = [
        " DP-3, 1920x1080@60, 0x0, 1" 
	" HDMI-A-1, 1920x1080@60, 1920x0, 1"
      ]; # monitor 
      # ecosystem = {
        # enforce_permissions = 1;
      # };

      general = {
        gaps_in = 5;
	gaps_out = 10;
	border_size = 2;
	"col.active_border" = "rgba(ff0000cc) rgba(ffa500cc) rgba(ffff00cc) rgba(00ff00cc) rgba(0000ffcc) rgba(4b0082cc) rgba(ee82eecc) 135deg";
        "col.inactive_border" = "rgba(33333388)";
	allow_tearing = false;
	layout = "dwindle";
      }; # general 

      windowrule = [
        "suppressevent maximize, class:.*"
	"nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
      ]; # windowrule 

      decoration = {
        rounding = 10;
	shadow = {
	  enabled = true;
	  range = 4;
	  render_power = 3;
	  color = "rgba(1a1a1aee)";
	}; # shadow 

	blur = {
	  enabled = true;
	  size = 5;
	  passes = 2;
          vibrancy = 0.1696;
	}; # blur 

      }; # decoration 

      animations = {
        enabled = "yes, please :)";
        bezier = [ "easeOutQuint,0.23,1,0.32,1"
	           "easeInOutCubic,0.65,0.05,0.36,1"
	           "linear,0,0,1,1"
	           "almostLinear,0.5,0.5,0.75,1.0"
	           "quick,0.15,0,0.1,1" 
	         ]; # bezier 
    
        animation = [ "global, 1, 10, default"
		      "border, 1, 5.39, easeOutQuint"
		      "windows, 1, 4.79, easeOutQuint"
		      "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
		      "windowsOut, 1, 1.49, linear, popin 87%"
		      "fadeIn, 1, 1.73, almostLinear"
		      "fadeOut, 1, 1.46, almostLinear"
		      "fade, 1, 3.03, quick"
		      "layers, 1, 3.81, easeOutQuint"
		      "layersIn, 1, 4, easeOutQuint, fade"
		      "layersOut, 1, 1.5, linear, fade"
		      "fadeLayersIn, 1, 1.79, almostLinear"
		      "fadeLayersOut, 1, 1.39, almostLinear"
		      "workspaces, 1, 1.94, almostLinear, fade"
		      "workspacesIn, 1, 1.21, almostLinear, fade"
		      "workspacesOut, 1, 1.94, almostLinear, fade" 
		    ]; # animation
      }; # animations 

      dwindle = {
        pseudotile = true;
	preserve_split = true;
      }; # dwindle 
      
      master = {
        new_status = "master";
      }; # master 
    }; # settings 
  }; # wayland.windowManager.hyprland 

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
