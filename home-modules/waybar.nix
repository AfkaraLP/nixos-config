{ config, pkgs, lib, ... }:

{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
	position = "top";
	height = 30;
      };
    }; # settings 
    style = ''
    '';
  }; # programs.waybar 
}
