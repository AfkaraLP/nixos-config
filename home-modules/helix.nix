{ config, pkgs, lib, ... }:
let
  helix-lsp-config = {
    language-server.rust-analyzer.config = { checkOnSave.allTargets = true; };
    language-server.nixd = {
      command = "nixd";
      formatting = { command = [ "alejandra" ]; };
      nixpkgs.expr =
        ''import (builtins.getFlake "/etc/nixos").inputs.nixpkgs { }'';
      options.nixos.expr =
        ''(builtins.getFlake "/etc/nixos").nixosConfigurations.bld0.options'';
    };
  };
in {

  programs.helix = {
    enable = true;
    settings = {
      theme = "term16_dark";
      editor = {
        soft-wrap.enable = true;
        line-number = "relative";
        shell = [ "nu" "--stdin" "-c" ];
        lsp.display-messages = true;

        indent-guides = { render = true; };

        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        }; # cursor-shape

        end-of-line-diagnostics = "hint";
        inline-diagnostics = { cursor-line = "warning"; };
      }; # editor
      keys.insert = {
        j.j = "normal_mode";
        esc = "no_op";
      }; # keys.insert
    }; # settings
    languages = helix-lsp-config;
  };
}
