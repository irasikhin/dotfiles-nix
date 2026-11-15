_:

# Core editor options, treesitter, base theme, leader key.
{
  programs.nvf.settings.vim = {
    options.clipboard = "unnamedplus";

    luaConfigRC.leader = ''
      vim.g.mapleader = ' '
      vim.g.formatsave = true
    '';

    # `clipboard=unnamedplus` needs a clipboard provider; without a compositor
    # (ssh into this host, plain tty) there is no wl-copy target and yanking
    # fails with "clipboard: No provider". Fall back to the builtin OSC 52
    # provider: the terminal (foot, `osc52 enabled` by default) then owns the
    # clipboard, so `"+y` / `"+p` work over ssh too.
    luaConfigRC.clipboard = ''
      if not (vim.env.WAYLAND_DISPLAY or vim.env.DISPLAY) then
        vim.g.clipboard = 'osc52'
      end
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
