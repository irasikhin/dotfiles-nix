{ config, pkgs, inputs, lib, ... }:

{
  home.username = "irasikhin";
  home.homeDirectory = "/home/irasikhin";
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
        python3
        nodejs-18_x
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
        fira-code-nerdfont
        librewolf
        pass
        xclip
        bc
        xorg.xev
        xbindkeys
        xorg.xmodmap
        networkmanagerapplet
        temurin-bin
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
        ansible
        chromium
        go-task
        dig
        busybox
        inetutils
        libreoffice-qt
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
        okular
	];
  
  programs.neovim = {
  	enable = true;
  	viAlias = true;
	  vimAlias = true;
    defaultEditor = true;
    extraLuaPackages = luaPkgs: with luaPkgs; [];
  };

	home.sessionVariables = {
		EDITOR="nvim";
	};
  home.sessionPath = ["$HOME/.config/scripts"];
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
      plugins = ["git" "docker" "fzf"];
    };

    history.size = 10000;
    history.ignoreAllDups = true;
    history.path = "$HOME/.zsh_history";
    history.ignorePatterns = ["rm *" "pkill *" "cp *"];

    antidote = {
      enable = true;
      plugins = [''
        zsh-users/zsh-autosuggestions
        ohmyzsh/ohmyzsh path:lib/git.zsh
      ''];
    };

    initExtra = ''
    byobu; 
    tput reset;
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
      # add_newline = false;

      # character = {
      #   success_symbol = "[➜](bold green)";
      #   error_symbol = "[➜](bold red)";
      # };

      # package.disabled = true;
    };
  };
}
