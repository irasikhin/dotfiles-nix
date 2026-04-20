{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    sensibleOnTop = false;
    shortcut = "a";
    baseIndex = 1;
    newSession = true;
    escapeTime = 0;
    secureSocket = false;

    plugins = with pkgs; [
      tmuxPlugins.better-mouse-mode
    ];

    keyMode = "vi";

    extraConfig = ''
      set -g default-terminal "tmux-256color"
      set -ga terminal-overrides ",*256col*:Tc"
      set -ga terminal-overrides '*:Ss=\E[%p1%d q:Se=\E[ q'
      set-environment -g COLORTERM "truecolor"

      set-option -g mouse on
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      # Dark theme (gruvbox hard)
      set -g status-style "bg=#1d2021,fg=#a89984"
      set -g status-left "#[bg=#98971a,fg=#1d2021,bold] #S #[bg=#1d2021,fg=#98971a] "
      set -g status-right "#[fg=#32302f]#[bg=#32302f,fg=#a89984] %H:%M #[bg=#a89984,fg=#1d2021,bold] #h "
      set -g status-left-length 30
      set -g status-right-length 50
      set -g window-status-format "#[fg=#665c54] #I:#W "
      set -g window-status-current-format "#[bg=#282828,fg=#d8a657,bold] #I:#W "
      set -g window-status-separator ""
      set -g pane-border-style "fg=#3c3836"
      set -g pane-active-border-style "fg=#98971a"
      set -g message-style "bg=#1d2021,fg=#a89984"
      set -g message-command-style "bg=#1d2021,fg=#a89984"

      bind -n M-Left  select-window -p
      bind -n M-Right select-window -n

      bind -n M-h select-pane -L
      bind -n M-j select-pane -D
      bind -n M-k select-pane -U
      bind -n M-l select-pane -R
    '';
  };

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "FiraCode Nerd Font:size=18";
        shell = "tmux";
      };
      colors = {
        background = "1d2021";
        foreground = "d4be98";
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
