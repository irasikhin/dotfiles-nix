{
  config,
  pkgs,
  lib,
  ...
}:

let
  nextcloudRoot = "${config.home.homeDirectory}/Nextcloud";
  keepassSyncDir = "${nextcloudRoot}/keepass";
  # Active Floorp profile (see ~/.floorp/profiles.ini -> Default=1). Host-specific.
  floorpProfile = ".floorp/vbsa7lco.default";
  # Floorp UI/content scale via layout.css.devPixelsPerPx — an ABSOLUTE
  # devicePixelRatio override (no double-scaling). Keep it equal to the sway
  # output scale of eDP-1 (1.5), which is what google-chrome renders at, so both
  # browsers come out the same size. If the output scale changes, change this too.
  floorpUiScale = "1.5";
in
{
  # Full icon theme so blueman-manager (and other GTK apps) resolve device
  # icons; hicolor alone lacks audio-headset/audio-headphones etc.
  # Theme: Gruvbox Dark (dark0_hard #1d2021, i.e. the darkest gruvbox variant).
  # Covers GTK3 apps and their dialogs -- LibreOffice, the
  # xdg-desktop-portal-gtk file chooser, GIMP/Remmina/Deluge -- which otherwise
  # fell back to light Adwaita. libadwaita (GTK4) apps ignore the theme name, so
  # gtk3.colorScheme only feeds them dconf color-scheme=prefer-dark.
  # Use tweakVariants = [ "black" ] for an even darker #141617 background.
  gtk = {
    enable = true;
    theme = {
      name = "Gruvbox-Dark";
      package = pkgs.gruvbox-gtk-theme.override {
        colorVariants = [ "dark" ];
        sizeVariants = [ "standard" ];
        themeVariants = [ "default" ];
      };
    };
    # dconf color-scheme=prefer-dark (libadwaita reads this); set on gtk3 so
    # Home Manager does not also emit the broken `gtk-interface-color-scheme`
    # key into gtk-4.0/settings.ini.
    gtk3.colorScheme = "dark";
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  # Lightweight Wayland PDF viewer (vim keys).
  programs.zathura.enable = true;

  # Custom URL scheme routing.
  # - http/https open Floorp directly (the default browser).
  # - The `browsers` picker (software.Browsers) is still installed and can be
  #   invoked on demand via a sway keybinding to choose a browser per link.
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/http" = "floorp.desktop";
      "x-scheme-handler/https" = "floorp.desktop";
      # Use the -pdf-mupdf entry: it declares MimeType=application/pdf, so it
      # shows up in mimeinfo.cache (Telegram et al. build their "open with"
      # list from that). The bare zathura.desktop has no MimeType line.
      "application/pdf" = "org.pwmt.zathura-pdf-mupdf.desktop";
    };
  };

  # The browser picker is a plain GTK app: it follows the sway output scale like
  # everything else, so no per-app GDK_SCALE/GDK_DPI_SCALE overrides are needed.
  xdg.desktopEntries."software.Browsers" = {
    type = "Application";
    name = "Browsers";
    comment = "Open the right browser at the right time";
    icon = "software.Browsers";
    exec = "${pkgs.browsers}/bin/browsers %u";
    terminal = false;
    startupNotify = true;
    categories = [
      "Network"
      "WebBrowser"
    ];
    mimeType = [
      "x-scheme-handler/http"
      "x-scheme-handler/https"
    ];
  };

  xdg.configFile."autostart/nextcloud.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Version=1.0
    Name=Nextcloud
    Comment=Sync Nextcloud in the background
    Exec=${pkgs.nextcloud-client}/bin/nextcloud --background
    Terminal=false
    StartupNotify=false
    X-GNOME-Autostart-enabled=true
  '';

  # Floorp: disable (not hide) the URL input field. The address bar stays
  # visible and shows the current URL, but the editable string is inert -- a
  # mouse click no longer focuses it. Appended idempotently (marker-guarded) so
  # the user's own userChrome.css edits are preserved.
  # NOTE: blocks pointer focus only. Keyboard shortcuts (Ctrl+L, Alt+D, F6,
  # Ctrl+K) can still focus it -- that needs an autoconfig package override,
  # which we can add if pointer-disable proves insufficient.
  home.activation.floorpDisableUrlbar = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        profile="${config.home.homeDirectory}/${floorpProfile}"
        [ -d "$profile" ] || exit 0
        userjs="$profile/user.js"
        css="$profile/chrome/userChrome.css"
        $DRY_RUN_CMD mkdir -p "$profile/chrome"

        if ! { [ -e "$userjs" ] && grep -q "legacyUserProfileCustomizations.stylesheets" "$userjs"; }; then
          echo 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' >> "$userjs"
        fi

        # HM:ui-scale -- explicit zoom; strip any prior managed line then re-add so
        # the value stays in sync with floorpUiScale across rebuilds.
        if [ -e "$userjs" ]; then
          $DRY_RUN_CMD sed -i '/HM:ui-scale/d' "$userjs"
        fi
        echo 'user_pref("layout.css.devPixelsPerPx", "${floorpUiScale}"); // HM:ui-scale' >> "$userjs"

        if ! { [ -e "$css" ] && grep -q "HM:disable-urlbar" "$css"; }; then
          cat >> "$css" <<'CSS'

    /* HM:disable-urlbar -- inert URL input (visible, not click-focusable) */
    @-moz-document url(chrome://browser/content/browser.xhtml) {
      #urlbar-input-container { pointer-events: none !important; }
      #urlbar-input { opacity: 0.7; }
    }
    CSS
        fi
  '';

  home.activation.setupKeepassNextcloud = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    nextcloud_root="${nextcloudRoot}"
    keepass_sync_dir="${keepassSyncDir}"
    keepass_link="${config.home.homeDirectory}/.keepass"

    $DRY_RUN_CMD mkdir -p "$nextcloud_root"
    $DRY_RUN_CMD mkdir -p "$keepass_sync_dir"

    if [ -L "$keepass_link" ]; then
      current_target="$($DRY_RUN_CMD readlink "$keepass_link")"
      if [ "$current_target" != "$keepass_sync_dir" ]; then
        echo "Expected $keepass_link to point to $keepass_sync_dir, but found $current_target" >&2
        exit 1
      fi
    elif [ -e "$keepass_link" ]; then
      echo "$keepass_link already exists and is not a symlink. Move it manually before enabling Nextcloud sync." >&2
      exit 1
    else
      $DRY_RUN_CMD ln -s "$keepass_sync_dir" "$keepass_link"
    fi
  '';
}
