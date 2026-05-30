{ pkgs, ... }:

{
  # Enable X server and configure display manager/window manager
  services.xserver.enable = true;

  # regreet is a graphical (GTK/Wayland) greeter for greetd. Unlike the previous
  # TUI greeter (ly), it can render an image background. programs.regreet.enable
  # auto-enables services.greetd and hosts regreet inside cage.
  programs.regreet = {
    enable = true;
    settings = {
      background = {
        # Mirrored here by the wallpaper-rotator user service (update_background_image.sh).
        # The greeter runs as the `greeter` user, which cannot read /home/ir, so the
        # blurred wallpaper is copied into a world-readable path (tmpfiles rule below).
        path = "/var/lib/greeter-wallpaper/bg.jpg";
        fit = "Cover";
      };
      GTK.application_prefer_dark_theme = true;
    };
  };

  # World-readable directory for the greeter background. Owned by `ir` so the
  # rotator (a user service running as ir) can write bg.jpg into it; 0755 + a
  # 0644 file lets the `greeter` user read it.
  systemd.tmpfiles.rules = [
    "d /var/lib/greeter-wallpaper 0755 ir users - -"
  ];

  # gnome-keyring provides the Secret Service (org.freedesktop.secrets) that
  # eXpress uses to store credentials. sway is not systemd-integrated here, so
  # the keyring is started and unlocked by PAM at greetd login (with the login
  # password) rather than via a graphical-session systemd target.
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  programs.sway = {
    enable = true;
    xwayland.enable = true;
    extraPackages = with pkgs; [
      waybar
      swaylock-effects
      swayidle
      swaybg
      grim
      slurp
      wl-clipboard
      fuzzel
      swaynotificationcenter
    ];
  };
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };
}
