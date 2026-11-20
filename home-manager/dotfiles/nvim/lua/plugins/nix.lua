-- NixOS: LSP servers, formatters and linters are installed by Nix
-- (home-manager/modules/packages.nix), so Mason's runtime downloads are off and
-- every server is looked up on $PATH instead.
return {
  { "mason.nvim", enabled = false },
  { "mason-org/mason.nvim", enabled = false },
  { "mason-lspconfig.nvim", enabled = false },
  { "mason-org/mason-lspconfig.nvim", enabled = false },
  { "mason-nvim-dap.nvim", enabled = false },

  -- Java: google-java-format on save; jdtls' own formatter stays off.
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = { java = { "google-java-format" } },
    },
  },
  {
    "mfussenegger/nvim-jdtls",
    optional = true,
    opts = {
      settings = {
        java = {
          format = { enabled = false },
        },
      },
    },
  },
}
