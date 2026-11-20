-- Test runner adapters on top of LazyVim's test.core extra.
-- Test binaries: cargo-nextest (rust) comes from Nix; vitest/jest come from the
-- project's own node_modules.
return {
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "rouge8/neotest-rust",
      "marilari88/neotest-vitest",
      "nvim-neotest/neotest-jest",
    },
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}
      vim.list_extend(opts.adapters, { "neotest-rust", "neotest-vitest", "neotest-jest" })
    end,
  },
}
