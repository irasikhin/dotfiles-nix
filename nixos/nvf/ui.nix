{ ... }:

# UI plugins, file picker bindings, terminal, git, navigation helpers.
{
  programs.nvf.settings.vim = {
    fzf-lua.enable = true;

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

    luaConfigRC.mini-files-bindings = ''
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
  };
}
