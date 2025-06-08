{ config, pkgs, lib, ... }:
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
  ]; # imports

  xdg.configFile."wpaperd/wallpaper.toml".source =
    (pkgs.formats.toml { }).generate "wallpaper_config_afkara" wallpaperConfig;
  services = {
    wpaperd = {
      enable = true;
      settings = { };
    }; # wpaperd
  }; # services

  home.stateVersion = "25.05";

  programs = { home-manager.enable = true; }; # programs
}
