{
  config,
  pkgs,
  lib,
  ...
}:

let
  nextcloudRoot = "${config.home.homeDirectory}/Nextcloud";
  keepassSyncDir = "${nextcloudRoot}/keepass";
in
{
  # Full icon theme so blueman-manager (and other GTK apps) resolve device
  # icons; hicolor alone lacks audio-headset/audio-headphones etc.
  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  # Lightweight Wayland PDF viewer (vim keys).
  programs.zathura.enable = true;

  # Custom URL scheme routing.
  # - http/https open through Junction so links launched by *other* apps
  #   (terminal, chat clients) pop an app picker instead of a hardcoded browser.
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/http" = "re.sonny.Junction.desktop";
      "x-scheme-handler/https" = "re.sonny.Junction.desktop";
      # Use the -pdf-mupdf entry: it declares MimeType=application/pdf, so it
      # shows up in mimeinfo.cache (Telegram et al. build their "open with"
      # list from that). The bare zathura.desktop has no MimeType line.
      "application/pdf" = "org.pwmt.zathura-pdf-mupdf.desktop";
    };
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
