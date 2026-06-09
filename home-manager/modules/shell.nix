{
  pkgs,
  config,
  flakeDir,
  ...
}:

let
  homeDir = config.home.homeDirectory;
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
    hs = "fc -rl 1 | fzf";
    ld = "lazydocker";
    psg = "procs";
    bw = "bandwhich";
    jv = "jless";
    sgp = "ast-grep";
    arthas = "jbang arthas@alibaba/arthas";
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };

  programs.broot = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.git = {
    enable = true;
    signing.format = null;
    settings = {
      merge.conflictStyle = "zdiff3";
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      line-numbers = true;
      side-by-side = true;
      hyperlinks = true;
      syntax-theme = "gruvbox-dark";
    };
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
      rebuild = "nh os switch . && nh home switch .";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "docker"
        "fzf"
        "kubectl"
        "helm"
        "mvn"
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

      bindkey -e

      # Load fzf-tab HERE, not via antidote: it must be sourced after compinit
      # (run by oh-my-zsh above) and after `fzf --zsh` (which binds TAB to its
      # own widget). Sourcing last lets fzf-tab claim TAB on a fully-initialised
      # completion system. Must still precede zsh-syntax-highlighting (loaded
      # after initContent), which is the case.
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh

      # fzf-tab: render the zsh completion menu through fzf.
      # `menu no` hands selection to fzf instead of zsh's builtin menu.
      zstyle ':completion:*' menu no
      # Accept current fzf candidate and keep completing (e.g. cd path segments).
      zstyle ':fzf-tab:*' continuous-trigger '/'
      zstyle ':fzf-tab:*' switch-group ',' '.'
      # Directory listing preview when completing cd.
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'

      # Maven module completion via fzf-tab.
      # omz `mvn` plugin uses old-style compctl (fzf-tab can't wrap it) and
      # only offers module *paths*. This compsys wrapper overrides it: reuses
      # omz's goal list, and after -rf/-pl offers `:artifactId` candidates so
      # `mvn ... -rf :<tab>` fuzzy-picks a module to resume from.
      __mvn_artifact_ids() {
        local pom
        for pom in **/pom.xml(N); do
          [[ $pom == *target/* ]] && continue
          # strip <parent>..</parent>, then take this module's own artifactId
          sed -e ':a' -e 'N' -e '$!ba' -e 's#<parent>.*</parent>##' "$pom" \
            | sed -n 's:.*<artifactId>[[:space:]]*\([^<]*\).*:\1:p' | head -1
        done
      }
      _mvn() {
        local prev=$words[CURRENT-1]
        local -a ids dirs reply
        case $prev in
          -rf|--resume-from)
            ids=(''${(f)"$(__mvn_artifact_ids)"})
            compadd -- ''${ids/#/:}
            return ;;
          -pl|--projects)
            ids=(''${(f)"$(__mvn_artifact_ids)"})
            dirs=(''${(f)"$(print -l **/pom.xml(-.N:h))"})
            compadd -- ''${ids/#/:} $dirs
            return ;;
        esac
        listMavenCompletions   # omz: fills $reply with goals/flags/modules
        compadd -a reply
      }
      compdef _mvn mvn mvnw mvn-color mvn-or-mvnw

      # terraform-style tools act as their own completer via the bash
      # `complete -C` protocol; bashcompinit bridges them into compsys
      # (so fzf-tab wraps them too).
      autoload -Uz bashcompinit && bashcompinit
      complete -o nospace -C tofu tofu
      complete -o nospace -C terragrunt terragrunt

      eval "$(navi widget zsh)"

      yy() {
        local tmp cwd
        tmp="$(mktemp -t yazi-cwd.XXXXXX)"
        yazi "$@" --cwd-file="$tmp"
        cwd="$(cat "$tmp" 2>/dev/null)"
        if [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
          cd "$cwd"
        fi
        rm -f "$tmp"
      }
    '';
  };

  # nix-locate / `, foo` runs any nixpkgs binary without installing.
  # Database comes prebuilt from nix-index-database flake input.
  programs.nix-index.enable = true;
  programs.nix-index-database.comma.enable = true;

  # nh: friendlier `nixos-rebuild` / `home-manager` wrapper with diffs.
  programs.nh = {
    enable = true;
    flake = flakeDir;
    clean = {
      enable = true;
      extraArgs = "--keep-since 7d --keep 5";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };

      package.disabled = true;
    };
  };
}
