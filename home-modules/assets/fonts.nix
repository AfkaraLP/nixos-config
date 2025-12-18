{ config, pkgs, lib, ... }:

{
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    fira-code
    monocraft
    jetbrains-mono
    victor-mono
  ]; # fonts.packages
}
