{ pkgs, lib, ... }:

{
  programs.zellij = {
    enable = true;
    # Home Manager's shell integration auto-starts zellij from any shell that is
    # not $TERM=dumb, and its SERVER keeps the environment of the FIRST client,
    # so a bare tty login (`login` -> zsh, TERM=linux) creates the "main" server
    # with no WAYLAND_DISPLAY and every pane spawned later inherits that broken
    # env -- see the guarded replacement in programs.zsh.initContent below.
    #
    # With the integration off, the two variables it exports (`attachExistingSession`
    # = false, `exitShellOnExit` = true) and the auto-start itself are restored
    # below, so nothing else changes.
    enableZshIntegration = false;

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

  # What Home Manager's zellij shell integration would otherwise export
  # (exitShellOnExit = true, attachExistingSession = false); the integration
  # itself is replaced below.
  home.sessionVariables = {
    ZELLIJ_AUTO_ATTACH = "false";
    ZELLIJ_AUTO_EXIT = "true";
  };

  # The zellij SERVER inherits the environment of its FIRST client, and every
  # pane (and every program in it) inherits the server's env -- not the env of
  # the terminal that is currently attached. Home Manager's stock integration
  # auto-starts zellij from any non-$TERM=dumb shell, so a tty login at boot
  # (`login` -> zsh, TERM=linux, no WAYLAND_DISPLAY) creates the "main" session
  # server. Attaching to it later from foot inside sway then leaves every pane
  # without WAYLAND_DISPLAY, and `wl-copy` is the clipboard provider for nvim
  # (`clipboard=unnamedplus`), zellij's own copy_command and cliphist -- so all
  # copying fails with "clipboard: No provider".
  #
  # Guard: only auto-attach where there is a display we can actually reach, and
  # as a belt-and-braces for a session born before this guard, let a pane that
  # inherited no display adopt the compositor socket itself.
  programs.zsh.initContent = lib.mkOrder 1500 ''
    if [[ -o interactive && -z "$ZELLIJ" && ( -n "$WAYLAND_DISPLAY" || -n "$DISPLAY" ) ]]; then
      eval "$(${pkgs.zellij}/bin/zellij setup --generate-auto-start zsh)"
    elif [[ -n "$ZELLIJ" && -z "$WAYLAND_DISPLAY" ]]; then
      for _wl_sock in "$XDG_RUNTIME_DIR"/wayland-[0-9]*(N); do
        [[ -S $_wl_sock ]] && export WAYLAND_DISPLAY=''${_wl_sock:t}
      done
      unset _wl_sock
    fi

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
        # pt size scales with the sway output scale (1.5 on eDP-1), so this is
        # 26px on screen (the pre-scale-1.5 equivalent was size=18 at scale 1.0,
        # now bumped a notch because 24px felt slightly small).
        font = "FiraCode Nerd Font:size=13";
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
