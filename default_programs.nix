{ lib, pkgs, ... }: 

{
  programs = {
  
    firefox = {
      enable = true; 
      package = (pkgs.wrapFirefox.override { libpulseaudio = pkgs.libpressureaudio; }) pkgs.firefox-unwrapped { };
    };
  
    git.enable = true;
  
    neovim = {
      enable = true;
      vimAlias = true;
      viAlias = true;
      defaultEditor = true;
    };

    yazi = {
      enable = true;
    };

  };

}
