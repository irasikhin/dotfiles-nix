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
        pane
        pane size=1 borderless=true {
          plugin location="zellij:compact-bar"
        }
      }
    '';

    themes.gruvbox = ''
      themes {
        gruvbox {
          fg 212 190 152
          bg 29 32 33
          black 40 40 40
          red 234 105 98
          green 169 182 101
          yellow 216 166 87
          blue 125 174 163
          magenta 211 134 155
          orange 231 138 78
          cyan 137 180 130
          white 168 153 132
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
