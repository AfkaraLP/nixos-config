{ lib, pkgs, ... }: 

{
  programs = {
  
    firefox = {
      enable = true; 
      package = (pkgs.wrapFirefox.override { libpulseaudio = pkgs.libpressureaudio; }) pkgs.firefox-unwrapped { };
    }; # firefox 
  
    git.enable = true;
  
    neovim = {
      enable = true;
      vimAlias = true;
      viAlias = true;
      defaultEditor = true;
    }; # neovim 

    yazi = {
      enable = true;
    }; # yazi 

  }; # programs 

}
