{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

let
  myHelm = pkgs.wrapHelm pkgs.kubernetes-helm {
    plugins = with pkgs.kubernetes-helmPlugins; [
      helm-diff
      helm-secrets
      helm-s3
    ];
  };
  myHelmfile = pkgs.helmfile.override {
    inherit (myHelm.passthru) pluginsDir;
  };
in
{
  home.username = "ir";
  home.homeDirectory = "/home/ir";
  home.stateVersion = "22.11";
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    htop
    unzip
    zip
    (pkgs.python3.withPackages (python-pkgs: [
      python-pkgs.pandas
      python-pkgs.requests
      python-pkgs.click
      python-pkgs.pyyaml
      python-pkgs.jinja2
      python-pkgs.distlib
      ansible
    ]))
    nodejs
    clang
    zig
    gnumake
    git
    lua
    lazygit
    bat
    fzf
    ripgrep
    jq
    tree
    eza
    alacritty
    kitty
    coreutils-prefixed
    screen
    tmux
    byobu
    fzf
    fd
    antigen
    docker
    zsh-autosuggestions
    pango
    fira-code
    nerd-fonts.fira-code
    librewolf
    pass
    xclip
    bc
    xorg.xev
    xbindkeys
    xorg.xmodmap
    networkmanagerapplet
    maven
    telegram-desktop
    font-awesome
    jetbrains.idea-community-bin
    acpi
    light # change brightness
    lshw # view gpu devices
    pamixer # sound control, configured in i3 config
    brillo # brightness control, configured in i3 config
    gparted
    parted
    bash
    feh
    imagemagick
    openconnect
    networkmanager-openconnect
    networkmanager-vpnc
    spotify
    ansible_2_17
    go-task
    dig
    busybox
    inetutils
    libreoffice
    cloc
    vscode
    zoom-us
    sshpass
    autorandr
    xlayoutdisplay
    oath-toolkit
    yamllint
    postgresql
    obsidian
    yq-go
    pnpm
    insomnia
    kubectl
    kustomize
    cointop
    quarkus
    qrencode
    httpie
    httpie-desktop
    bruno
    skopeo
    nmap
    kind
    sops
    age
    myHelm
    myHelmfile
    cargo
    aria2
    proxychains
    speedtest-cli
    nh
    p7zip
    xarchiver
    yandex-disk
    ungoogled-chromium
    jira-cli-go
    opentofu
    terranix
    terragrunt
    tflint
    nixfmt-rfc-style
    npins
    treefmt
    jdt-language-server
    mergiraf
    nil
    floorp
    yandex-music
    ytt
    redocly
    clang
    clang-tools
    xorg.libX11
    xorg.libXi
    boost
    meson
    inkscape
    openapi-generator-cli
    gimp
    jmeter
    librechat
    allure
    aider-chat
    aichat
    electrum
    ollama-rocm
    google-chrome
    jbang
    flameshot
    appimage-run
    python311Packages.psycopg2
    opentofu
    woeusb-ng
    k9s
    deluge
    parted
    python312Packages.click
    dbeaver-bin
    vhs
  ];

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
    plugins = [
      {
        plugin = pkgs.vimPlugins.gruvbox-nvim;
      }
    ];
    extraConfig = ''
      colorscheme gruvbox
      set clipboard=unnamedplus
    '';
  };

  home.sessionVariables = {
    EDITOR = "nvim";
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
      byobu; 
      tput reset;
      source /home/ir/jira.sh;
    '';
  };

  home.file."${config.xdg.configHome}" = {
    source = ./dotfiles;
    recursive = true;
  };

  programs.tmux = {
    enable = true;
    sensibleOnTop = false;
    shortcut = "a";
    # aggressiveResize = true; -- Disabled to be iTerm-friendly
    baseIndex = 1;
    newSession = true;
    # Stop tmux+escape craziness.
    escapeTime = 0;
    # Force tmux to use /tmp for sockets (WSL2 compat)
    secureSocket = false;

    plugins = with pkgs; [
      tmuxPlugins.better-mouse-mode
    ];

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
    # Configuration written to ~/.config/starship.toml
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
