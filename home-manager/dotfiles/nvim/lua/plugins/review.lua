-- Code review: local branch/commit review with diffview, GitHub PR review with
-- octo (needs the `gh` CLI, installed in home-manager/modules/neovim.nix).
return {
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewRefresh",
      "DiffviewFileHistory",
    },
    keys = {
      { "<leader>gv", "<cmd>DiffviewOpen<CR>", desc = "Review changes since merge base" },
      { "<leader>gV", "<cmd>DiffviewOpen origin/HEAD...HEAD<CR>", desc = "Review branch vs origin" },
      { "<leader>gH", "<cmd>DiffviewFileHistory %<CR>", desc = "File history" },
      { "<leader>gq", "<cmd>DiffviewClose<CR>", desc = "Close diff view" },
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        default = { layout = "diff2_horizontal" },
        merge_tool = { layout = "diff3_mixed" },
      },
    },
  },

  {
    "pwntester/octo.nvim",
    cmd = "Octo",
    event = { { event = "BufReadCmd", pattern = "octo://*" } },
    opts = {
      enable_builtin = true,
      default_to_projects_v2 = true,
      picker = "snacks",
    },
    keys = {
      { "<leader>gpr", "<cmd>Octo pr list<CR>", desc = "Review pull requests" },
      { "<leader>gir", "<cmd>Octo issue list<CR>", desc = "Review issues" },
    },
    config = function(_, opts)
      require("octo").setup(opts)
      vim.treesitter.language.register("markdown", "octo")
    end,
  },
}
