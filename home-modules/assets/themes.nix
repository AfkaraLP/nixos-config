{ config, pkgs, lib, ...}:

{
  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 16;
  }; # home.pointerCursor 


  gtk = {
    enable = true;

    theme = {
      package = pkgs.flat-remix-gtk;
      name = "Flat-Remix-GTK-Grey-Darkest";
    }; # theme 

    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    }; # iconTheme 

    font = {
      name = "Fira Code";
      size = 11;
    }; # font 
  }; # gtk 
}
