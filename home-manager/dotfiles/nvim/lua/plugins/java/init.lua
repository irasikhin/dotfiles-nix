-- This file is much simpler now.
-- Nix handles the installation and pathing of jdtls, lombok, and debug adapters.
return {
  "mfussenegger/nvim-jdtls",
  ft = { "java" },
  dependencies = { "folke/which-key.nvim" },
  config = function()
    -- The wrapper script for jdtls provided by nixpkgs
    -- automatically finds debug adapters and other bundles.
    -- We just need to start it.

    local jdtls_setup = require("jdtls.setup")
    local root_markers = { ".git", "mvnw", "gradlew", "pom.xml" }
    local root_dir = jdtls_setup.find_root(root_markers)
    if not root_dir then
      return
    end

    local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
    local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls/" .. project_name

    -- See `:help jdtls-config` for more options.
    local config = {
      -- Your custom JVM options.
      -- Note: 12g is a LOT of memory. Consider starting lower, e.g., -Xmx4g
      cmd = { "jdtls", "-Xmx4g", "-Xms1g", "--jvm-arg=-XX:+UseG1GC" },
      root_dir = root_dir,
      workspace_dir = workspace_dir,
      settings = {
        java = {
          inlayHints = {
            parameterNames = {
              enabled = "all",
            },
          },
        },
      },
      init_options = {
        bundles = {},
      },
      on_attach = function(client, bufnr)
        -- Your existing keymaps and LspAttach logic from the old file can be pasted here.
        -- It remains valid.
        local wk = require("which-key")
        wk.add({
          {
            mode = "n",
            buffer = bufnr,
            { "<leader>cx", group = "extract" },
            { "<leader>cxv", function() require("jdtls").extract_variable_all(false) end, desc = "Extract Variable" },
            { "<leader>cxc", function() require("jdtls").extract_constant(false) end, desc = "Extract Constant" },
            { "<leader>cgs", require("jdtls").super_implementation, desc = "Goto Super" },
            { "<leader>cgS", require("jdtls.tests").goto_subjects, desc = "Goto Subjects" },
            { "<leader>co", require("jdtls").organize_imports, desc = "Organize Imports" },
          },
          {
            mode = "v",
            buffer = bufnr,
            { "<leader>cx", group = "extract" },
            { "<leader>cxm", [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]], desc = "Extract Method" },
          },
        })

        -- Setup DAP. It's much cleaner now.
        require("jdtls").setup_dap({ hotcodereplace = "auto" })
        wk.add({
          {
            mode = "n",
            buffer = bufnr,
            { "<leader>t", group = "test" },
            { "<leader>tt", function() require("jdtls.dap").test_class() end, desc = "Run All Test" },
            { "<leader>tr", function() require("jdtls.dap").test_nearest_method() end, desc = "Run Nearest Test" },
            { "<leader>tT", require("jdtls.dap").pick_test, desc = "Run Test" },
          },
        })
      end,
    }

    require("jdtls").start_or_attach(config)
  end,
}
