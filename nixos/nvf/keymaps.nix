_:

# All <leader>-prefixed keybindings.
{
  programs.nvf.settings.vim.keymaps = [
    {
      key = "<leader>e";
      mode = "n";
      action = "<cmd>ToggleMiniFiles<CR>";
      desc = "Toggle files";
    }
    {
      key = "<leader>ff";
      mode = "n";
      action = "<cmd>FzfLua files<CR>";
      desc = "Find files";
    }
    {
      key = "<leader>fg";
      mode = "n";
      action = "<cmd>FzfLua live_grep<CR>";
      desc = "Live grep";
    }
    {
      key = "<leader>fb";
      mode = "n";
      action = "<cmd>FzfLua buffers<CR>";
      desc = "Find buffers";
    }
    {
      key = "<leader>fh";
      mode = "n";
      action = "<cmd>FzfLua help_tags<CR>";
      desc = "Help tags";
    }
    {
      key = "<leader>fm";
      mode = "n";
      action = "<cmd>FzfLua lsp_document_symbols<CR>";
      desc = "Document symbols";
    }
    {
      key = "<leader>fc";
      mode = "n";
      action = "<cmd>FzfLua lsp_live_workspace_symbols<CR>";
      desc = "Workspace classes/symbols";
    }
    {
      key = "<leader>w";
      mode = "n";
      action = "<cmd>write<CR>";
      desc = "Write buffer";
    }
    {
      key = "<leader>q";
      mode = "n";
      action = "<cmd>quit<CR>";
      desc = "Quit window";
    }
    {
      key = "<leader>tt";
      mode = "n";
      action = "<cmd>ToggleTerm<CR>";
      desc = "Toggle terminal";
    }
    {
      key = "<leader>u";
      mode = "n";
      action = "<cmd>UndotreeToggle<CR>";
      desc = "Toggle undo tree";
    }
    {
      key = "<leader>cs";
      mode = "n";
      action = "<cmd>AerialToggle<CR>";
      desc = "Toggle symbols outline";
    }
    {
      key = "<leader>jo";
      mode = "n";
      action = "<cmd>lua vim.lsp.buf.code_action({ apply = true, context = { only = { 'source.organizeImports' } } })<CR>";
      desc = "Java organize imports";
    }
    {
      key = "<leader>jr";
      mode = "n";
      action = "<cmd>lua vim.lsp.buf.rename()<CR>";
      desc = "Java rename symbol";
    }
    {
      key = "<leader>jm";
      mode = "n";
      action = "<cmd>lua vim.lsp.buf.code_action({ context = { only = { 'refactor.extract.function' } } })<CR>";
      desc = "Java extract method";
    }
    {
      key = "<leader>jv";
      mode = "n";
      action = "<cmd>lua vim.lsp.buf.code_action({ context = { only = { 'refactor.extract.variable' } } })<CR>";
      desc = "Java extract variable";
    }
    {
      key = "<leader>jc";
      mode = "n";
      action = "<cmd>lua vim.lsp.buf.code_action({ context = { only = { 'refactor.extract.constant' } } })<CR>";
      desc = "Java extract constant";
    }
    {
      key = "<leader>ji";
      mode = "n";
      action = "<cmd>lua vim.lsp.buf.code_action({ context = { only = { 'refactor.inline' } } })<CR>";
      desc = "Java inline refactor";
    }
    {
      key = "<leader>gd";
      mode = "n";
      action = "<cmd>DiffviewOpen<CR>";
      desc = "Open git diff";
    }
    {
      key = "<leader>gD";
      mode = "n";
      action = "<cmd>DiffviewClose<CR>";
      desc = "Close git diff";
    }
    {
      key = "<leader>gh";
      mode = "n";
      action = "<cmd>DiffviewFileHistory %<CR>";
      desc = "File history";
    }
    {
      key = "<leader>xx";
      mode = "n";
      action = "<cmd>Trouble toggle diagnostics<CR>";
      desc = "Workspace diagnostics";
    }
    {
      key = "<leader>xX";
      mode = "n";
      action = "<cmd>Trouble toggle diagnostics filter.buf=0<CR>";
      desc = "Buffer diagnostics";
    }
    {
      key = "<leader>xq";
      mode = "n";
      action = "<cmd>Trouble toggle quickfix<CR>";
      desc = "Quickfix list";
    }
    {
      key = "<leader>xl";
      mode = "n";
      action = "<cmd>Trouble toggle loclist<CR>";
      desc = "Location list";
    }
    {
      key = "<leader>xs";
      mode = "n";
      action = "<cmd>Trouble toggle symbols<CR>";
      desc = "Symbols list";
    }
    {
      key = "<leader>xr";
      mode = "n";
      action = "<cmd>Trouble toggle lsp_references<CR>";
      desc = "LSP references";
    }
  ];
}
