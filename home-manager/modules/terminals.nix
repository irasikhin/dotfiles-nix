{ pkgs, lib, ... }:

{
  # tmux-which-key ships only config.example.yaml in the read-only nix store;
  # its runtime copy lands read-only (cp keeps the store's 0444), so autobuild
  # can't overwrite init.tmux and the plugin aborts (set -e -> returns 1, menu
  # never sourced). Seed WRITABLE copies in the XDG paths it uses so autobuild
  # succeeds. Edit ~/.config/tmux/plugins/tmux-which-key/config.yaml to
  # customize the menu (rebuilt on next tmux start).
  home.activation.tmuxWhichKey = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    src="${pkgs.tmuxPlugins.tmux-which-key}/share/tmux-plugins/tmux-which-key"
    cfg="$HOME/.config/tmux/plugins/tmux-which-key"
    dat="$HOME/.local/share/tmux/plugins/tmux-which-key"
    run mkdir -p "$cfg" "$dat"
    [ -f "$cfg/config.yaml" ] || run install -m 644 "$src/config.example.yaml" "$cfg/config.yaml"
    [ -f "$dat/init.tmux" ]   || run install -m 644 "$src/plugin/init.example.tmux" "$dat/init.tmux"
    run chmod u+w "$cfg/config.yaml" "$dat/init.tmux"
  '';

  programs.tmux = {
    enable = true;
    prefix = "C-Space";
    keyMode = "vi";
    mouse = true;
    escapeTime = 10; # low → reliable Alt/Meta keys in foot
    historyLimit = 50000;
    baseIndex = 1;
    terminal = "tmux-256color";

    # Plugin order matters: the gruvbox theme must load FIRST (it owns
    # status-left/right + window formats), and continuum must load LAST —
    # continuum appends its autosave hook to status-right when it loads, so
    # nothing may re-set status-right after it (HM emits the main extraConfig
    # AFTER all plugins, so status-* lives here, not in extraConfig).
    plugins = with pkgs.tmuxPlugins; [
      # ---- THEME (first: owns the status bar) ----
      {
        plugin = gruvbox; # egel/tmux-gruvbox
        extraConfig = ''
          set -g @tmux-gruvbox 'dark'
          # LOCK/PREFIX/NORMAL chip re-injected as the left segment
          # (segment bg is #665c54; reset to it after each colored state).
          # NOTE: this value is embedded by egel inside its own status-left, so the
          # whole thing is parsed as tmux #{?cond,true,false} conditionals. Commas
          # inside the #[...] style blocks MUST be escaped as #, — an unescaped comma
          # ends the conditional branch early and the leftover (e.g. `nobold]`) prints
          # literally in the bar.
          set -g @tmux-gruvbox-left-status-a "#{?#{==:#{client_key_table},off},#[bg=#fb4934#,fg=#1d2021#,bold] L #[bg=#665c54#,fg=#bdae93#,nobold],#{?client_prefix,#[bg=#fabd2f#,fg=#1d2021#,bold] P #[bg=#665c54#,fg=#bdae93#,nobold],#[bg=#b8bb26#,fg=#1d2021#,bold] N #[bg=#665c54#,fg=#bdae93#,nobold]}}"
          # Right side: cpu·ram · load · session·clock. Metrics via #() with
          # bc-less commands (top us+sy, free, /proc/loadavg). egel keeps the
          # gruvbox colours; we only fill its three slots.
          set -g @tmux-gruvbox-right-status-x " #(top -bn1 | awk '/^%?Cpu/{printf \"%.0f%%\",$2+$4;exit}')  󰍛 #(free | awk '/^Mem/{printf \"%.0f%%\",$3/$2*100}')"
          set -g @tmux-gruvbox-right-status-y "󰊚 #(cut -d' ' -f1 /proc/loadavg)"
          set -g @tmux-gruvbox-right-status-z "#H  #S  %H:%M"
        '';
      }

      # ---- Clipboard (wl-copy auto-detected on wayland) ----
      {
        plugin = yank;
        extraConfig = "set -g @yank_selection_mouse 'clipboard'";
      }

      # ---- Fuzzy grab text / paths / urls (needs fzf) ----
      extrakto # prefix+Tab
      fzf-tmux-url # prefix+u
      {
        plugin = tmux-thumbs; # prefix+i (off Space to avoid which-key)
        extraConfig = "set -g @thumbs-key i";
      }

      # ---- Session management ----
      sessionist # prefix+g switch / +C new / +X kill / +@ promote
      {
        plugin = tmux-sessionx; # prefix+O
        extraConfig = ''
          set -g @sessionx-bind 'O'
          set -g @sessionx-zoxide-mode 'on'
        '';
      }

      # ---- Menus / discoverability ----
      {
        plugin = tmux-fzf; # prefix+F
        extraConfig = ''TMUX_FZF_LAUNCH_KEY="F"'';
      }
      {
        plugin = tmux-which-key; # prefix+Space menu
        # nixpkgs ships only config.example.yaml in the read-only store, so the
        # plugin's in-store copy/build fails (returns 1). XDG mode makes it copy
        # the example to ~/.config/tmux/plugins/tmux-which-key/config.yaml and
        # build init.tmux under ~/.local/share (both writable). Edit that
        # config.yaml to customize the menu.
        extraConfig = ''
          set -g @tmux-which-key-xdg-enable 1
        '';
      }

      # ---- Persistence: resurrect, then continuum LAST ----
      {
        plugin = resurrect; # prefix+C-s save / prefix+C-r restore
        extraConfig = ''
          set -g @resurrect-capture-pane-contents 'on'
          set -g @resurrect-strategy-nvim 'session'
        '';
      }
      {
        plugin = continuum; # MUST be last (appends its hook to status-right)
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '10'
        '';
      }
    ];

    extraConfig = ''
      # ---- Truecolor + foot correctness ----
      set -ga terminal-features ",foot*:RGB"
      set -ga terminal-features ",foot*:usstyle"
      set -ga terminal-overrides ",foot*:Tc"

      # ---- Modified-key handling: extended keys (CSI-u) OFF ----
      # extended-keys lets apps tell Ctrl+Backspace / Shift+Enter / Ctrl+Enter
      # apart, but on tmux 3.6a it makes foot send Alt+arrow in the extended
      # form, which the plain `M-Left` bindings below do NOT match -> pane nav
      # dies. We don't use those modified keys, so keep it off and keep reliable
      # Alt+arrow nav (the proven pre-ee45209 state). Only re-enable alongside
      # explicit user-keys byte-bindings for Alt+arrow; see ee45209 oscillation.

      # ---- QoL ----
      set -g focus-events on
      set -g renumber-windows on
      setw -g aggressive-resize on
      setw -g pane-base-index 1
      set -g detach-on-destroy off
      set -g display-time 2000
      set -g display-panes-time 2000

      # ---- Clipboard / passthrough ----
      set -g set-clipboard on      # OSC52 (foot supports it; works over ssh)
      set -g allow-passthrough on  # yazi/chafa image preview, sixel, OSC passthrough

      # ---- Status position (egel theme owns the rest of the bar) ----
      set -g status-position top
      set -g status-interval 5

      # ---- Pane borders: tint flips on prefix (amber) / lock (red) ----
      set -g pane-border-style "fg=#3c3836"
      set -g pane-active-border-style "#{?client_prefix,fg=#d8a657,#{?#{==:#{client_key_table},off},fg=#ea6962,fg=#89b482}}"

      # ---- Alt+arrow nav (root table, no prefix) ----
      # Up/Down move panes. Left/Right move panes too, but when already at the
      # leftmost/rightmost pane they flow to the previous/next window instead
      # (#{pane_at_left/right} = pure tmux, no helper script).
      bind -n M-Left  if -F '#{pane_at_left}'  'previous-window' 'select-pane -L'
      bind -n M-Right if -F '#{pane_at_right}' 'next-window'     'select-pane -R'
      bind -n M-Up    select-pane -U
      bind -n M-Down  select-pane -D

      # ---- Splits / new window open in current dir ----
      bind '"' split-window -v -c "#{pane_current_path}"
      bind %   split-window -h -c "#{pane_current_path}"
      bind c   new-window   -c "#{pane_current_path}"

      # ---- Copy-mode (vi) polish ----
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi C-v send -X rectangle-toggle
      bind -T copy-mode-vi y send -X copy-pipe-and-cancel 'wl-copy'
      bind -T copy-mode-vi Escape send -X cancel
      # copy on mouse drag-release, then exit copy-mode (no sticky highlight /
      # stuck copy-mode state). Use Shift+drag for foot's native selection.
      bind -T copy-mode-vi MouseDragEnd1Pane send -X copy-pipe-and-cancel 'wl-copy'

      # ---- Reload config ----
      bind r source-file ~/.config/tmux/tmux.conf \; display "tmux.conf reloaded"

      # ---- Popups: lazygit + sesh session switcher ----
      bind G display-popup -E -w 90% -h 90% -d "#{pane_current_path}" lazygit
      bind o display-popup -E -w 80% -h 70% "sesh connect \"$(sesh list --icons | fzf --ansi --no-sort --prompt '⚡ ' --border-label ' sesh ')\""

      # ============================================================
      #  LOCK toggle (M-x): blank prefix + disable keybinds so keys
      #  pass straight to the app. M-x again restores.
      # ============================================================
      bind -n M-x \
        set prefix None \;\
        set key-table off \;\
        refresh-client -S
      bind -T off M-x \
        set -u prefix \;\
        set -u key-table \;\
        refresh-client -S

      # ---- Inner panes spawn zsh (not /bin/sh); also makes $TMUX-guard work ----
      set -g default-command "${pkgs.zsh}/bin/zsh"
    '';
  };

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "FiraCode Nerd Font:size=18";
        shell = "${pkgs.zsh}/bin/zsh";
      };
      colors-dark = {
        background = "1d2021";
        foreground = "d4be98";
        # explicit selection (default inverts fg/bg → unreadable on gruvbox);
        # solid cream block w/ dark text, visible across local + ssh'd tmux panes
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
