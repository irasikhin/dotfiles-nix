{ pkgs, ... }:

let
  homeDir = "/home/ir";
in
{
  # Enable X server and configure display manager/window manager
  services.xserver.enable = true;
  services.displayManager.ly.enable = true;
  services.displayManager.ly.settings = {
    animation = "matrix";
    bigclock = "en";
    full_color = true;
    border_fg = "0x00458588";
    cmatrix_fg = "0x00458588";
    error_fg = "0x01fb4934";
    error_bg = "0x001d2021";
  };
  services.displayManager.defaultSession = "sway"; # Use sway as default session
  services.xserver.windowManager.i3 = {
    enable = true;
    extraPackages = with pkgs; [
      rofi # Application launcher
      i3status-rust # Status bar for i3
      i3lock-color # Lock screen
      i3lock-fancy # Fancier lock screen
    ];
  };
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
  programs.xss-lock = {
    enable = true;
    lockerCommand = ''
      ${pkgs.i3lock-color}/bin/i3lock-color \
        --image ${homeDir}/.background-image-blur \
        --clock \
        --time-str="%H:%M:%S" \
        --date-str="%A, %d %B" \
        --time-size=48 \
        --date-size=20 \
        --time-color=eceff4ff \
        --date-color=eceff4cc \
        --ring-color=4c566aff \
        --ringver-color=4c566aff \
        --ringwrong-color=bf616aff \
        --inside-color=000000cc \
        --insidever-color=000000cc \
        --insidewrong-color=000000cc \
        --line-uses-ring \
        --keyhl-color=ffffffff \
        --bshl-color=ff00ffff \
        --radius=90 \
        --ring-width=8 \
        --indicator \
        -k --keylayout 0
    '';
  };
}
