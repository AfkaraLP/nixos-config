{ config, pkgs, lib, ... }:
let
  wallpaperConfig = {
    default = {
      path = "/home/afkara/wallpapers";
      duration = "1m";
      sorting = "random";
    }; # default 
  }; # wallpaperConfig 

  nixvim = import (
    builtins.fetchGit {
      url = "https://github.com/nix-community/nixvim";
      ref = "nixos-unstable";
    }
  );
in
{
  home.username = "afkara";
  home.homeDirectory = "/home/afkara";

  imports = [
    ./home-modules/hyprland.nix
    ./home-modules/terminal.nix
  ]; # imports 

  home.packages = with pkgs; [
    vesktop
    bat
  ]; # home.packages 

  xdg.configFile."wpaperd/wallpaper.toml".source = (pkgs.formats.toml { }).generate "wallpaper_config_afkara" wallpaperConfig;

  services = {
    wpaperd = {
      enable = true;
      settings = {};
    }; # wpaperd 
  }; # services 
  
  home.stateVersion = "24.11";

  programs = {
    home-manager.enable = true;
  }; # programs 
}
