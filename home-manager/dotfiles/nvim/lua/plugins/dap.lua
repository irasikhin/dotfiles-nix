-- Debug adapters. Mason is disabled, so instead of mason-nvim-dap the
-- adapters are pointed straight at the binaries installed by Nix
-- (home-manager/modules/neovim.nix exposes their paths via config.nix-paths).
local paths = require("config.nix-paths")

return {
  {
    "mfussenegger/nvim-dap",
    optional = true,
    config = function()
      local dap = require("dap")

      -- TypeScript / JavaScript: vscode-js-debug (`js-debug` on PATH).
      -- js-debug listens on IPv4 localhost (second arg is the bind host).
      dap.adapters["pwa-node"] = {
        type = "server",
        host = "127.0.0.1",
        port = "${port}",
        executable = {
          command = "js-debug",
          args = { "${port}", "127.0.0.1" },
        },
      }
      for _, ft in ipairs({ "javascript", "javascriptreact", "typescript", "typescriptreact" }) do
        dap.configurations[ft] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            cwd = vim.fn.getcwd(),
            sourceMaps = true,
          },
          {
            type = "pwa-node",
            request = "attach",
            name = "Attach to node process",
            processId = require("dap.utils").pick_process,
            cwd = vim.fn.getcwd(),
          },
        }
      end

      -- C / C++ / Zig: CodeLLDB.
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = paths.codelldb,
          args = { "--liblldb", paths.codelldb_lib, "--port", "${port}" },
        },
      }
      local codelldb_launch = {
        {
          name = "Launch file",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
      }
      dap.configurations.c = codelldb_launch
      dap.configurations.cpp = codelldb_launch
      dap.configurations.zig = codelldb_launch
    end,
  },

  -- Rust: rustaceanvim owns the debugger configuration.
  {
    "mrcjkb/rustaceanvim",
    optional = true,
    opts = function(_, opts)
      opts.dap = {
        adapter = require("rustaceanvim.config").get_codelldb_adapter(paths.codelldb, paths.codelldb_lib),
      }
    end,
  },

  -- Java: hand nvim-jdtls the java-debug/java-test bundles.
  {
    "mfussenegger/nvim-jdtls",
    optional = true,
    opts = {
      jdtls = {
        init_options = {
          bundles = vim.fn.glob(paths.java_debug_bundles .. "/*.jar", false, true),
        },
      },
    },
  },
}
