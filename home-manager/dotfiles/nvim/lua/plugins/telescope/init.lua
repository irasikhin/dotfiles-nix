return {
  {
    "nvim-telescope/telescope.nvim",
    enabled = false,
    opts = {
      defaults = {
        path_display = {
          shorten = 5,
          filename_first = {},
        },
      },
    },
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    enabled = false,
    opts = nil,
  },
}
