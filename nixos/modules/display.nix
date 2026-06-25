{ pkgs, ... }:

let
  # sddm-astronaut is a Qt6 SDDM theme. We pin the "cyberpunk" embedded variant
  # and point its Background at the rotated wallpaper that the wallpaper-rotator
  # user service mirrors into /var/lib/greeter-wallpaper/bg.jpg. themeConfig is
  # written as a *.conf.user override on top of the embedded theme, so only these
  # keys change. The image is the sharp wallpaper (not blurred) — we want concrete
  # imagery on the login screen, lightly dimmed for text legibility.
  sddmAstronaut = pkgs.sddm-astronaut.override {
    embeddedTheme = "cyberpunk";
    themeConfig = {
      Background = "/var/lib/greeter-wallpaper/bg.jpg";
      CropBackground = "true";
      DimBackground = "0.25";

      # De-red the cyberpunk variant: its form is built on #FF003C (red) and
      # #ca0174 (magenta). Recolor backgrounds to dark and text/icons/accents to
      # the theme's own cyan (#00F0FF) so the cyberpunk vibe stays but nothing is
      # red. Warning kept alerting via amber. A couple of contrast fixes
      # (DropdownText / HighlightText) since their backgrounds changed.
      # Field / dropdown backgrounds (were #FF003C):
      LoginFieldBackgroundColor = "#2A2A3A";
      PasswordFieldBackgroundColor = "#2A2A3A";
      DropdownBackgroundColor = "#2A2A3A";
      # Login button: gruvbox-style — neutral orange fill, dark text.
      LoginButtonBackgroundColor = "#d65d0e";
      LoginButtonTextColor = "#282828";
      # Text / icons (were #FF003C):
      DateTextColor = "#00F0FF";
      # Button icons/text: gruvbox bright orange.
      SystemButtonsIconsColor = "#fe8019";
      SessionButtonTextColor = "#fe8019";
      VirtualKeyboardButtonTextColor = "#fe8019";
      WarningColor = "#FFB000";
      # Accents / hovers (were #ca0174 magenta):
      HeaderTextColor = "#00F0FF";
      PlaceholderTextColor = "#6C7086";
      DropdownSelectedBackgroundColor = "#00F0FF";
      HighlightBackgroundColor = "#00F0FF";
      HighlightBorderColor = "#00F0FF";
      HighlightTextColor = "#21222C";
      HoverUserIconColor = "#00F0FF";
      HoverPasswordIconColor = "#00F0FF";
      # Button hovers: gruvbox bright yellow.
      HoverSystemButtonsIconsColor = "#fabd2f";
      HoverSessionButtonTextColor = "#fabd2f";
      HoverVirtualKeyboardButtonTextColor = "#fabd2f";
      # Contrast fix: dropdown list bg is now dark, needs light text.
      DropdownTextColor = "#F8F8F2";
    };
  };
in
{
  # SDDM (Qt6) replaces the regreet/greetd greeter, which crash-looped on the
  # latest nixpkgs (relm4/GTK SIGABRT at launch). SDDM renders a real image
  # background via the sddm-astronaut theme and is far more stable. We run the
  # Wayland greeter to keep the system X-free (sway is the only session).
  services.displayManager = {
    defaultSession = "sway";
    sddm = {
      enable = true;
      wayland.enable = true;
      package = pkgs.kdePackages.sddm; # Qt6 sddm, required by sddm-astronaut
      theme = "sddm-astronaut-theme";
      # The theme's Qt6 QML deps (multimedia/svg/virtualkeyboard) must be present
      # for the greeter to render; they ride along via the theme package.
      extraPackages = sddmAstronaut.propagatedBuildInputs;
    };
  };
  # Install the theme so SDDM finds it under …/share/sddm/themes.
  environment.systemPackages = [ sddmAstronaut ];

  # World-readable directory for the login-screen background. Owned by `ir` so the
  # rotator (a user service running as ir) can write bg.jpg into it; 0755 dir + a
  # 0644 file lets the `sddm` greeter user read it.
  systemd.tmpfiles.rules = [
    "d /var/lib/greeter-wallpaper 0755 ir users - -"
  ];

  # gnome-keyring provides the Secret Service (org.freedesktop.secrets) that
  # eXpress uses to store credentials. sway is not systemd-integrated here, so
  # the keyring is started and unlocked by PAM at sddm login (with the login
  # password) rather than via a graphical-session systemd target.
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;

  # Clamshell: with an external display connected the lid can be closed, the
  # session keeps running on the external monitor. Without external (on battery)
  # it's a normal suspend. "Docked" is determined by logind itself via kernel DRM
  # connectors, independent of sway, so detection is reliable. Also covers the
  # login screen (greetd/regreet), where sway isn't running yet and logind
  # handles the lid.
  services.logind = {
    lidSwitch = "suspend";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "ignore";
  };

  # Wake-on-USB for the clamshell "closed first, plugged in later" scenario:
  # the laptop with no monitor goes to suspend, and a keypress on the external
  # USB keyboard wakes it. xHCI controllers already have ACPI-wake (S3,
  # /proc/acpi/wakeup), so it's enough to enable power/wakeup on the device
  # itself. We trigger on the HID interface event (boot keyboard = class 03,
  # protocol 01) and write to the wakeup of the parent usb_device via ../. The
  # mouse (protocol 02) is intentionally left alone so an accidental mouse move
  # doesn't wake the system; a key on a combo receiver wakes it anyway (shared
  # usb_device).
  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_interface", ATTR{bInterfaceClass}=="03", ATTR{bInterfaceProtocol}=="01", ATTR{../power/wakeup}="enabled"
  '';

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
