return {
  -- Darkest gruvbox (contrast = "hard").
  {
    "ellisonleao/gruvbox.nvim",
    lazy = false,
    priority = 1000,
    opts = { contrast = "hard" },
  },

  { "LazyVim/LazyVim", opts = { colorscheme = "gruvbox" } },
}
