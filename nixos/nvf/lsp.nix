_:

# LSP, completion, snippets.
{
  programs.nvf.settings.vim = {
    lsp.enable = true;
    lsp.trouble.enable = true;

    autocomplete.nvim-cmp.enable = true;
    snippets.luasnip.enable = true;
  };
}
