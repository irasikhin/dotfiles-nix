-- Language support LazyVim has no extra for, plus a few missing linters.
-- All binaries come from home-manager/modules/neovim.nix.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "xml", "dtd", "sql" } },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- XML
        lemminx = {},
        -- shell scripts
        bashls = {},
        -- SQL (no LazyVim extra for this one)
        sqls = {},
        -- Clojure: the LazyVim extra only adds Conjure, no LSP
        clojure_lsp = {},
      },
    },
  },

  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.xml = { "xmlformat" }
    end,
  },

  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.sh = { "shellcheck" }
      opts.linters_by_ft.yaml = { "yamllint" }
    end,
  },
}
