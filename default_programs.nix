{ config, lib, pkgs, ... }:

{
  programs = {
    alvr = {
      enable = true;
      openFirewall = true;
    };
    gamemode.enable = true;
    gamescope = {
      enable = true;
      capSysNice = true;
    };

    hyprland = {
      enable = true;
      xwayland.enable = true;
    };


    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    git.enable = true;

    yazi = { enable = true; }; # yazi

  }; # programs

}

