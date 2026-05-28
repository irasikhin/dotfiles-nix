{ pkgs, ... }:

# Batch 4 additions: oil, neogit, conform, nvim-dap, codecompanion,
# render-markdown. Uses nvf built-in modules where available; render-markdown
# pulled in via extraPlugins (no nvf module).
{
  programs.nvf.settings.vim = {
    utility.oil-nvim = {
      enable = true;
      gitStatus.enable = true;
    };

    git.neogit.enable = true;

    formatter.conform-nvim = {
      enable = true;
      setupOpts.format_on_save = null;
    };

    debugger.nvim-dap = {
      enable = true;
      ui.enable = true;
    };

    assistant.codecompanion-nvim.enable = true;

    extraPlugins.render-markdown = {
      package = pkgs.vimPlugins.render-markdown-nvim;
      setup = "require('render-markdown').setup({})";
    };
  };
}
