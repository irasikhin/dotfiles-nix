-- Autocmds run after LazyVim's own setup.

-- Java: Google style, 2-space indent.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function(args)
    vim.bo[args.buf].shiftwidth = 2
    vim.bo[args.buf].tabstop = 2
    vim.bo[args.buf].softtabstop = 2
  end,
})
