{ ... }:

# Per-language enables + Java-specific tweaks (formatter, jdtls tuning).
{
  programs.nvf.settings.vim = {
    languages = {
      markdown.enable = true;
      rust.enable = true;
      typescript.enable = true;
      python.enable = true;
      nix.enable = true;
      java.enable = true;
      clojure = {
        enable = true;
        lsp.enable = true;
      };
    };

    # Java: 2-space indent, on-save format via google-java-format.
    luaConfigRC.java-format = ''
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'java',
        callback = function(args)
          vim.b[args.buf].disableFormatSave = true
          vim.bo[args.buf].shiftwidth = 2
          vim.bo[args.buf].tabstop = 2
          vim.bo[args.buf].softtabstop = 2
        end,
      })

      vim.api.nvim_create_autocmd('BufWritePre', {
        pattern = '*.java',
        callback = function(args)
          local view = vim.fn.winsaveview()
          local lines = vim.api.nvim_buf_get_lines(args.buf, 0, -1, false)
          local formatted = vim.fn.systemlist({ 'google-java-format', '-' }, lines)

          if vim.v.shell_error ~= 0 then
            vim.notify('google-java-format failed', vim.log.levels.ERROR)
            return
          end

          vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, formatted)
          vim.fn.winrestview(view)
        end,
      })
    '';

    # jdtls: per-project workspace, JVM tuning, disable expensive features.
    luaConfigRC.jdtls-tuning = ''
      local jdtls_config = vim.lsp.config["jdtls"]
      if jdtls_config then
        local workspace_root = vim.fn.stdpath("data") .. "/jdtls-workspaces"
        local workspace_name = vim.fs.basename(vim.fn.getcwd()) .. "-" .. vim.fn.sha256(vim.fn.getcwd()):sub(1, 12)
        local workspace_dir = workspace_root .. "/" .. workspace_name

        vim.fn.mkdir(workspace_root, "p")

        local cmd = vim.deepcopy(jdtls_config.cmd or {})
        if #cmd >= 5 and cmd[4] == "-data" then
          cmd[5] = workspace_dir
        end

        jdtls_config.cmd = cmd
        jdtls_config.cmd_env = vim.tbl_deep_extend("force", jdtls_config.cmd_env or {}, {
          JAVA_TOOL_OPTIONS = table.concat({
            "-Xms1g",
            "-Xmx6g",
            "-XX:MaxMetaspaceSize=1g",
            "-XX:+UseG1GC",
            "-XX:+UseStringDeduplication",
            "-XX:ReservedCodeCacheSize=512m",
            "-Dsun.zip.disableMemoryMapping=true",
          }, " "),
        })
        jdtls_config.flags = vim.tbl_deep_extend("force", jdtls_config.flags or {}, {
          allow_incremental_sync = true,
          debounce_text_changes = 500,
        })
        jdtls_config.settings = vim.tbl_deep_extend("force", jdtls_config.settings or {}, {
          java = {
            autobuild = {
              enabled = false,
            },
            configuration = {
              updateBuildConfiguration = "interactive",
            },
            format = {
              enabled = false,
            },
            implementationsCodeLens = {
              enabled = false,
            },
            project = {
              resourceFilters = {
                ".git",
                ".direnv",
                ".cache",
                "node_modules",
                "target",
                "build",
                "dist",
              },
            },
            referencesCodeLens = {
              enabled = false,
            },
            signatureHelp = {
              enabled = true,
            },
          },
        })
      end
    '';
  };
}
