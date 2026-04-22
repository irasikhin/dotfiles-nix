{ pkgs, ... }:

{
  # Enable X server and configure display manager/window manager
  services.xserver.enable = true;
  services.displayManager.ly.enable = true;
  services.displayManager.ly.settings = {
    animation = "colormix";
    bigclock = "en";
    blank_password = true;
    load = false;
    save = false;
    full_color = true;
    border_fg = "0x008fbcbb";
    cmatrix_fg = "0x0081a1c1";
    colormix_col1 = "0x002e3440";
    colormix_col2 = "0x003b4252";
    colormix_col3 = "0x0081a1c1";
    error_fg = "0x01bf616a";
    error_bg = "0x002e3440";
  };
  services.displayManager.defaultSession = "sway"; # Use sway as default session
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
