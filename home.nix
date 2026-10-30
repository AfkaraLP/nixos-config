{ config, pkgs, ... }:
let
  wallpaperConfig = {
    default = {
      path = "/home/afkara/wallpapers";
      duration = "1m";
      sorting = "random";
    }; # default
  }; # wallpaperConfig
in {
  home.username = "afkara";
  home.homeDirectory = "/home/afkara";

  imports = [
    ./home-modules/terminal.nix
    ./home-modules/assets/fonts.nix
    ./home-modules/waybar.nix
    ./home-modules/assets/themes.nix
    ./home-modules/fuzzel.nix
    ./home-modules/helix.nix
    ./home-modules/spicetify.nix
    ./home-modules/discord.nix
  ]; # imports

  xdg.configFile."wpaperd/wallpaper.toml".source =
    (pkgs.formats.toml { }).generate "wallpaper_config_afkara" wallpaperConfig;

  # Use SteamVR's live manifest so OpenXR follows Steam-managed runtime updates.
  xdg.configFile."openxr/1/active_runtime.json".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.local/share/Steam/steamapps/common/SteamVR/steamxr_linux64.json";

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/bsmanager" = [ "BSManager.desktop" ];
      "x-scheme-handler/beatsaver" = [ "BSManager.desktop" ];
      "x-scheme-handler/bsplaylist" = [ "BSManager.desktop" ];
      "x-scheme-handler/modelsaber" = [ "BSManager.desktop" ];
      "x-scheme-handler/web+bsmap" = [ "BSManager.desktop" ];
    };
  };
  services = {
    wpaperd = {
      enable = true;
      settings = { };
    }; # wpaperd
  }; # services

  home.stateVersion = "24.11";

  programs = { home-manager.enable = true; }; # programs
}
