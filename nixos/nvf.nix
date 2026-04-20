{ ... }:

{
  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        options.clipboard = "unnamedplus";
        luaConfigRC.language-defaults = ''
          vim.g.mapleader = ' '

          vim.g.formatsave = true

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

        languages = {
          markdown.enable = true;
          rust.enable = true;
          ts.enable = true;
          python.enable = true;
          nix.enable = true;
          java.enable = true;
          clojure = {
            enable = true;
            lsp.enable = true;
          };
        };

        treesitter.enable = true;
        treesitter.context.enable = true;
        binds.whichKey.enable = true;
        fzf-lua.enable = true;

        autocomplete.nvim-cmp.enable = true;
        snippets.luasnip.enable = true;

        lsp.enable = true;
        lsp.trouble.enable = true;

        mini = {
          comment.enable = true;
          cursorword.enable = true;
          files.enable = true;
          icons.enable = true;
          indentscope.enable = true;
          pairs.enable = true;
          statusline.enable = true;
          surround.enable = true;
          tabline.enable = true;
        };

        git = {
          enable = true;
          gitsigns.enable = true;
        };

        projects.project-nvim.enable = true;
        terminal.toggleterm = {
          enable = true;
          lazygit.enable = true;
        };
        utility = {
          diffview-nvim.enable = true;
          undotree.enable = true;
          motion.flash-nvim.enable = true;
          outline.aerial-nvim.enable = true;
        };

        ui.illuminate.enable = true;
        notes.todo-comments.enable = true;
        notify.nvim-notify.enable = true;

        luaConfigRC.mini-navigation = ''
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

          local show_dotfiles = true

          local filter_show = function(fs_entry)
            return true
          end

          local filter_hide = function(fs_entry)
            return not vim.startswith(fs_entry.name, '.')
          end

          local toggle_mini_files = function()
            if not MiniFiles.close() then
              local buf_name = vim.api.nvim_buf_get_name(0)
              local target = buf_name ~= "" and buf_name or vim.uv.cwd()
              MiniFiles.open(target, true)
            end
          end

          local toggle_dotfiles = function()
            show_dotfiles = not show_dotfiles
            local new_filter = show_dotfiles and filter_show or filter_hide
            MiniFiles.refresh({ content = { filter = new_filter } })
          end

          vim.api.nvim_create_autocmd('User', {
            pattern = 'MiniFilesBufferCreate',
            callback = function(args)
              local buf_id = args.data.buf_id
              vim.keymap.set('n', '<CR>', MiniFiles.go_in, { buffer = buf_id, desc = 'Open entry' })
              vim.keymap.set('n', 'l', MiniFiles.go_in, { buffer = buf_id, desc = 'Open entry' })
              vim.keymap.set('n', 'h', MiniFiles.go_out, { buffer = buf_id, desc = 'Go out' })
              vim.keymap.set('n', 'q', MiniFiles.close, { buffer = buf_id, desc = 'Close files' })
              vim.keymap.set('n', '.', MiniFiles.show_help, { buffer = buf_id, desc = 'Show help' })
              vim.keymap.set('n', 'g.', toggle_dotfiles, { buffer = buf_id, desc = 'Toggle dotfiles' })
            end,
          })

          vim.api.nvim_create_user_command("ToggleMiniFiles", toggle_mini_files, {
            desc = "Toggle mini.files",
          })
        '';

        keymaps = [
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

        theme = {
          enable = true;
          name = "gruvbox";
          style = "dark";
        };
      };
    };
  };
}
