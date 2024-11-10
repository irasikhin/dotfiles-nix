return {
  -- add gruvbox
  { "ellisonleao/gruvbox.nvim", priority = 1000, config = true, opts = {
    contrast = "dark",
  } },
  { "xiantang/darcula-dark.nvim" },
  { "navarasu/onedark.nvim" },
  { "Mofiqul/vscode.nvim" },
  { "santos-gabriel-dario/darcula-solid.nvim" },
  { "projekt0n/github-nvim-theme", name = "github-theme" },
  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },
}
