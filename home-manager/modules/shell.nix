{ ... }:

let
  homeDir = "/home/ir";
in
{
  home.sessionVariables = {
    EDITOR = "nvim";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    GDK_DPI_SCALE = "1.4";
    MOZ_ENABLE_WAYLAND = "1";
  };

  xresources.properties = {
    "Xft.dpi" = 140;
  };

  home.sessionPath = [ "$HOME/.config/scripts" ];
  home.shellAliases = {
    l = "eza";
    ls = "eza";
    cat = "bat";
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [
      "--cmd j"
    ];
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      wdapp = "hwatch \"docker ps --format '{{.ID}} {{.Names}}' | grep application\"";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "docker"
        "fzf"
        "kubectl"
        "helm"
      ];
    };

    history.size = 10000;
    history.ignoreAllDups = true;
    history.path = "$HOME/.zsh_history";
    history.ignorePatterns = [
      "rm *"
      "pkill *"
      "cp *"
    ];

    antidote = {
      enable = true;
      plugins = [
        ''
          zsh-users/zsh-autosuggestions
          ohmyzsh/ohmyzsh path:lib/git.zsh
        ''
      ];
    };

    initContent = ''
      source ${homeDir}/jira.sh;
    '';
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;

      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };

      package.disabled = true;
    };
  };
}
