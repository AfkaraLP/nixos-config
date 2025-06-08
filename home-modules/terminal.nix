{ config, pkgs, lib, ...}:

{
  programs = {

    nushell = {
      enable = true;

      shellAliases = {
        nrs = "sudo nixos-rebuild switch";
        la = "ls -a";
        ll = "ls -la";
        l = "ls";
      };
    };

    zoxide = {
      enable = true;
      enableNushellIntegration = true;
    }; # zoxide

    wezterm = {
      enable = true;
      extraConfig = ''
        local config = wezterm.config_builder()
    	  enable_wayland = false

        config.default_prog = { "nu" }

     	  config.font = wezterm.font 'Jetbrains Mono'
        config.font_size = 12.0
        config.hide_tab_bar_if_only_one_tab = true
        config.window_background_opacity = 0.5
        config.window_close_confirmation = "NeverPrompt"
        config.window_padding = {
          left = 2,
          top = 0,
          bottom = 2,
          right = 2,
        }
        config.window_decorations = "NONE"
        config.window_frame = { inactive_titlebar_bg = "#000000", }

        return config
      '';

    }; # wezterm
  }; # programs 
}
