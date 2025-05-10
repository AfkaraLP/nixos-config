{ config, pkgs, lib, ... }:

{
  fonts.fontconfig.enable = true;
  
  home.packages = with pkgs; [
    fira-code
  ]; # fonts.packages 
}
