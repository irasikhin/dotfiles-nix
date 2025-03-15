return {
  "nvim-java/nvim-java",
  config = false,
  dependencies = {
    {
      "neovim/nvim-lspconfig",
      opts = {
        servers = {
          jdtls = {
            java = {
              settings = {
                format = {
                  enabled = false,
                },
              },
            },
          },
        },
        setup = {
          jdtls = function()
            require("java").setup({
              -- Your custom nvim-java configuration goes here
              root_markers = {
                ".git/backend/pom.xml",
              },
            })
          end,
        },
      },
    },
  },
}
