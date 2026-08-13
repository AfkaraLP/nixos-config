{ config, pkgs, lib, ... }: {
  programs.vicinae = {
    enable = true;
  };
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        # wezterm as default terminal if you use "fuzzel -t"
        terminal = "${pkgs.wezterm}/bin/wezterm";
        layer = "overlay";
        icon-theme = "Papirus-Dark";
        font = "Fira Code:size=11";
        width = 50;
        horizontal-pad = 16;
        vertical-pad = 12;
        line-height = 24;
        prompt = "";
        fields = "name,generic";
      };

      colors = {
        # RGBA colors (last two digits are alpha)
        background = "1e1e2ecc"; # dark semi-transparent for Hyprland blur
        text = "e0e0e0ff";
        match = "ffffffff";
        selection = "3b82f6cc"; # soft blue highlight
        selection-text = "ffffffff";
        border = "3b82f6ff";
      };

      border = {
        width = 2;
        radius = 12;
      };

      dmenu = { exit-immediately-if-empty = true; };
    };
  };

}
