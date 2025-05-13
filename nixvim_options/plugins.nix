{ config, pkgs, lib, nixvim, ... }: 

{
  programs.nixvim.plugins = {
	  lazy.enable = true;
	  guess-indent.enable = true;
	  cmp-snippy.enable = true;
        telescope.enable = true;
        lualine.enable = true;
        snacks.enable = true;
        fzf-lua.enable = true;
        which-key.enable = true;
        mini = {
          enable = true;
          # mockDevIcons = true;
        }; # mini
        oil.enable = true;
        blink-cmp.enable = true;
        lazydev.enable = true;
        bufferline.enable = true;
        noice.enable = true;
	transparent.enable = true;
        trouble.enable = true;
        conform-nvim = {
	  enable = true;
	  settings = {
	    format_after_save.lsp_format = "first";
	  };
	}; # conform-nvim 

        lsp = {
          enable = true;
	  inlayHints = true;

          servers = {
            rust_analyzer = {
              enable = true;
            };
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
