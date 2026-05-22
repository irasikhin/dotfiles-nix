_:

# Core editor options, treesitter, base theme, leader key.
{
  programs.nvf.settings.vim = {
    options.clipboard = "unnamedplus";

    luaConfigRC.leader = ''
      vim.g.mapleader = ' '
      vim.g.formatsave = true
    '';

    treesitter.enable = true;
    treesitter.context.enable = true;
    binds.whichKey.enable = true;

    theme = {
      enable = true;
      name = "gruvbox";
      style = "dark";
    };
  };
}
