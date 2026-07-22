{ pkgs, lib, ... }:

{
  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
    exitShellOnExit = true;

    settings = {
      theme = "gruvbox";
      default_shell = "${pkgs.zsh}/bin/zsh";
      session_name = "main";
      attach_to_session = true;
      pane_frames = false;
      mouse_mode = true;
      show_startup_tips = false;

      copy_command = "wl-copy";
      copy_clipboard = "system";
      copy_on_select = true;

      support_kitty_keyboard_protocol = false;

      session_serialization = true;
      pane_viewport_serialization = true;
      scrollback_lines_to_serialize = 10000;
    };

    layouts.default = ''
      layout {
        pane size=1 borderless=true {
          plugin location="zellij:tab-bar"
        }
        pane
        pane size=1 borderless=true {
          plugin location="zellij:status-bar"
        }
      }
    '';

    themes.gruvbox = ''
      themes {
        gruvbox {
          text_unselected {
            base 168 153 132
            background 40 40 40
            emphasis_0 231 138 78
            emphasis_1 137 180 130
            emphasis_2 169 182 101
            emphasis_3 211 134 155
          }
          text_selected {
            base 29 32 33
            background 212 190 152
            emphasis_0 231 138 78
            emphasis_1 137 180 130
            emphasis_2 169 182 101
            emphasis_3 211 134 155
          }
          ribbon_unselected {
            base 40 40 40
            background 212 190 152
            emphasis_0 234 105 98
            emphasis_1 168 153 132
            emphasis_2 125 174 163
            emphasis_3 211 134 155
          }
          ribbon_selected {
            base 40 40 40
            background 169 182 101
            emphasis_0 234 105 98
            emphasis_1 231 138 78
            emphasis_2 211 134 155
            emphasis_3 125 174 163
          }
          table_title {
            base 169 182 101
            emphasis_0 231 138 78
            emphasis_1 137 180 130
            emphasis_2 169 182 101
            emphasis_3 211 134 155
          }
          table_cell_unselected {
            base 168 153 132
            background 40 40 40
            emphasis_0 231 138 78
            emphasis_1 137 180 130
            emphasis_2 169 182 101
            emphasis_3 211 134 155
          }
          table_cell_selected {
            base 168 153 132
            background 29 32 33
            emphasis_0 231 138 78
            emphasis_1 137 180 130
            emphasis_2 169 182 101
            emphasis_3 211 134 155
          }
          list_unselected {
            base 168 153 132
            background 40 40 40
            emphasis_0 231 138 78
            emphasis_1 137 180 130
            emphasis_2 169 182 101
            emphasis_3 211 134 155
          }
          list_selected {
            base 168 153 132
            background 29 32 33
            emphasis_0 231 138 78
            emphasis_1 137 180 130
            emphasis_2 169 182 101
            emphasis_3 211 134 155
          }
          frame_selected {
            base 169 182 101
            emphasis_0 231 138 78
            emphasis_1 137 180 130
            emphasis_2 211 134 155
            emphasis_3 0
          }
          frame_highlight {
            base 231 138 78
            emphasis_0 211 134 155
            emphasis_1 0
            emphasis_2 231 138 78
            emphasis_3 231 138 78
          }
          exit_code_success {
            base 169 182 101
            emphasis_0 137 180 130
            emphasis_1 40 40 40
            emphasis_2 211 134 155
            emphasis_3 125 174 163
          }
          exit_code_error {
            base 234 105 98
            emphasis_0 216 166 87
            emphasis_1 0
            emphasis_2 0
            emphasis_3 0
          }
        }
      }
    '';

    extraConfig = ''
      keybinds {
        shared_except "locked" {
          bind "Alt g" { Run "lazygit" { floating true; close_on_exit true; }; }
        }
      }
    '';
  };

  programs.zsh.initContent = lib.mkOrder 1500 ''
    if [[ -n "$ZELLIJ" ]]; then
      autoload -Uz add-zsh-hook
      _zellij_rename_tab() {
        local name=''${PWD:t}
        [[ $PWD == $HOME ]] && name='~'
        [[ $PWD == / ]] && name='/'
        command zellij action rename-tab "$name" >/dev/null 2>&1
      }
      add-zsh-hook chpwd _zellij_rename_tab
      _zellij_rename_tab
    fi
  '';

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "FiraCode Nerd Font:size=18";
        shell = "${pkgs.zsh}/bin/zsh";
        # copy-on-select into clipboard AND primary: Shift+drag and plain drag
        # land the selection in the clipboard immediately. The highlight stays =
        # visual "what got copied"; clear it with a single left click. Default is
        # `primary` (clipboard apps / Ctrl+Shift+V saw nothing → felt uncopyable).
        selection-target = "both";
      };
      colors-dark = {
        background = "1d2021";
        foreground = "d4be98";
        # explicit selection (default inverts fg/bg → unreadable on gruvbox);
        # solid cream block w/ dark text, visible across local + ssh'd panes
        selection-foreground = "1d2021";
        selection-background = "d4be98";
        regular0 = "1d2021";
        regular1 = "ea6962";
        regular2 = "a9b665";
        regular3 = "d8a657";
        regular4 = "7daea3";
        regular5 = "d3869b";
        regular6 = "89b482";
        regular7 = "a89984";
        bright0 = "928374";
        bright1 = "ea6962";
        bright2 = "a9b665";
        bright3 = "d8a657";
        bright4 = "7daea3";
        bright5 = "d3869b";
        bright6 = "89b482";
        bright7 = "d4be98";
      };
    };
  };
}
