{ config, pkgs, lib, unstablePkgs, ...}:

let
  helix-lsp-config = {
     language-server.rust-analyzer.config = {
        checkOnSave.allTargets = true;
      };
    language-server.nixd = {
      command = "nixd";
      formatting = {
        command = ["alejandra"];
      };
      nixpkgs.expr = "import (builtins.getFlake \"/etc/nixos\").inputs.nixpkgs { }";
      options.nixos.expr = "(builtins.getFlake \"/etc/nixos\").nixosConfigurations.bld0.options";
    };
  };
in
{
  programs = {

    nushell = {
      enable = true;

      shellAliases = {
        nrs = "sudo nixos-rebuild switch";
        la = "ls -a";
        ll = "ls -la";
        l = "ls";
      };

      settings = {
        show_banner = false;
      };


    };

    zoxide = {
      enable = true;
      enableNushellIntegration = true;
    }; # zoxide

    wezterm = {
      enable = true;
      extraConfig = ''
        local config = wezterm.config_builder()
    	  enable_wayland = false

        config.default_prog = { "nu" }

     	  config.font = wezterm.font 'Fira Code'
        config.font_size = 12.0
        config.hide_tab_bar_if_only_one_tab = true
        config.window_background_opacity = 0.5
        config.window_close_confirmation = "NeverPrompt"
        config.window_padding = {
          left = 2,
          top = 0,
          bottom = 2,
          right = 2,
        }
        config.window_decorations = "NONE"
        config.window_frame = { inactive_titlebar_bg = "#000000", }

        return config
      '';

    }; # wezterm

    helix = {
      package = unstablePkgs.helix;
      enable = true;
        settings = {
          theme = "base16_transparent";
          editor = {
            soft-wrap.enable = true;
            line-number = "relative";
            shell = [ "nu" "--stdin" "-c" ];
            lsp.display-messages = true;
            cursor-shape = {
              insert = "bar";
              normal = "block";
              select = "underline";
            };
            end-of-line-diagnostics = "hint";
            inline-diagnostics = {
              cursor-line = "warning";
            };
          };
          keys.insert = {
            j.j = "normal_mode";
            esc = "no_op";
          };
        };
        languages = helix-lsp-config;
      };
  }; # programs 

}
