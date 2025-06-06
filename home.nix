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
    ./home-modules/hyprland.nix
    ./home-modules/terminal.nix
    ./home-modules/waybar.nix
    # ./home-modules/nixcord.nix
    ./home-modules/assets/fonts.nix
    ./home-modules/wofi.nix
  ]; # imports

  home.packages = with pkgs; [
    nil
    helix
    dconf
    bat
    sway-contrib.grimshot
    wl-clipboard
    bottom
    wineWowPackages.waylandFull
    easyeffects
    typst
    tinymist
    (discord.override {
      withVencord = true;
    })
  ]; # home.packages

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
