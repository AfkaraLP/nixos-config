{ config, pkgs, lib, nixvim, ... }:

{
  programs.nixvim.plugins = {
    guess-indent.enable = true;
    cmp-snippy.enable = true;
    telescope.enable = true;
    lualine.enable = true;
    snacks.enable = true;
    fzf-lua.enable = true;
    which-key.enable = true;
    nvim-tree = {
      enable = true;

      diagnostics.enable = true;
      git.enable = true;
      view.relativenumber = true;
    }; # nvim-tree 
    mini = {
      enable = true;
    }; # mini
    oil.enable = true;
    blink-cmp.enable = true;
    lazydev.enable = true;
    cmp.enable = true;
    bufferline.enable = true;
    noice.enable = true;
    efmls-configs = {
      enable = true;

      setup = {
        all.linter = "alex";
        nix = {
          formatter = "nixfmt";
          linter = "statix";
        }; # nix
        rust = { formatter = "rustfmt"; };
        lua.formatter = "stylua";
        html.formatter = "prettier";
        json.formatter = "prettier";
      }; # setup
    }; # efmls-configs
    transparent.enable = true;
    trouble.enable = true;
    conform-nvim = {
      enable = true;
      settings = { format_after_save.lsp_format = "first"; };
    }; # conform-nvim

    lsp = {
      enable = true;
      inlayHints = true;

      servers = {
        rust_analyzer = { enable = true; };
        nixd.enable = true;
        jsonls.enable = true;
        tailwindcss.enable = true;
        html.enable = true;
        jedi_language_server.enable = true;
        yamlls.enable = true;
        quick_lint_js.enable = true;
        bashls.enable = true;
      }; # servers
    }; # lsp};
  }; # nixvim.plugins
}
