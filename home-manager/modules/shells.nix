# Manages shell configuration (zsh, tmux, etc.)
{ pkgs, ... }: {
  home.packages = with pkgs; [ screen tmux byobu zsh-autosuggestions antigen ];

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [ "--cmd j" ];
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "docker" "fzf" "kubectl" "helm" ];
    };
    history = {
      size = 10000;
      ignoreAllDups = true;
      path = "$HOME/.zsh_history";
      ignorePatterns = [ "rm *" "pkill *" "cp *" ];
    };
    antidote = {
      enable = true;
      plugins = [ "zsh-users/zsh-autosuggestions" ];
    };
    initExtra = ''
      if command -v byobu >/dev/null 2>&1; then
        byobu
      fi
      if [ -f "$HOME/jira.sh" ]; then
        source "$HOME/jira.sh"
      fi
      tput reset
    '';
  };

  programs.tmux = {
    enable = true;
    sensibleOnTop = false;
    shortcut = "a";
    baseIndex = 1;
    newSession = true;
    escapeTime = 0;
    secureSocket = false;
    plugins = with pkgs.tmuxPlugins; [ better-mouse-mode ];
    extraConfig = ''
      set -g default-terminal "tmux-256color"
      set -ga terminal-overrides ",*256col*:Tc"
      set -ga terminal-overrides '*:Ss=\E[%p1%d q:Se=\E[ q'
      set-environment -g COLORTERM "truecolor"
      set-option -g mouse on
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"
    '';
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      character = { success_symbol = "[➜](bold green)"; error_symbol = "[➜](bold red)"; };
      package.disabled = true;
    };
  };

  xdg.configFile."byobu" = {
    source = ../dotfiles/byobu;
    recursive = true;
  };
}
