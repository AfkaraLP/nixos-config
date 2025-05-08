{ config, pkgs, lib, ...}:

{

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

      exec = [
        "gsettings set org.gnome.desktop.interface color-scheme \"prefer-dark\""
        "gsettings set org.gnome.desktop.interface gtk-theme \"adw-gtk3\""
      ];

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
        "col.active_border" = "rgba(d80000ee) rgba(ff5e5eee) 135deg";
        "col.inactive_border" = "rgba(3a3a3aaa)";
        allow_tearing = false;
        layout = "dwindle";
      }; # general

      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
        "QT_QPA_PLATFORMTHEME,qt6ct"
      ]; # env

      windowrule = [
        "suppressevent maximize, class:.*"
        "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
      ]; # windowrule

      windowrulev2 = [
        # "decoration:0;class:.*" #
        "noblur, class:firefox"
        "decorate off, class:.*"
      ]; # windowrulev2

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

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
      }; # misc

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
}
