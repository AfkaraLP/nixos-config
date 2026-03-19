{ config, pkgs, lib, unstablePkgs, ... }:

{
  programs = {
    zellij.enable = true;

    direnv = {
      enable = true;
      enableNushellIntegration = true;
      silent = true;
    };

    nushell = {
      enable = true;

      shellAliases = {
        nrs = "sudo nixos-rebuild switch";
        la = "ls -a";
        ll = "ls -la";
        l = "ls";
      };

      settings = { show_banner = false; };

      extraEnv = ''
          $env.EDITOR = 'hx'
          $env.PATH = ($env.PATH | append /home/afkara/.cargo/bin)
        '';

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

            config.color_scheme = 'Catppuccin Mocha'
         	  config.font = wezterm.font('Victor Mono', { weight = 'Bold' })
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
