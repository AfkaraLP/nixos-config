{ config, pkgs, lib,... }:

{
  home.username = "afkara";
  home.homeDirectory = "/home/afkara";

  home.packages = with pkgs; [
    neofetch
  ];

  # programs.enable ...

  home.stateVersion = "24.11";

  programs.home-manager.enable = true;
}
