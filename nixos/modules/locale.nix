_:

{
  # Set system locale and time zone
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Moscow";

  # Additional locale settings
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };

  # Keyboard layouts
  services.xserver.xkb = {
    layout = "us,ru"; # Enable US and Russian keyboard layouts
    options = "grp:shifts_toggle"; # Toggle layout with both Shifts (ctrl_shift collided with terminal copy/paste). Split uses a dedicated F24 key bound in sway.
  };

  console.keyMap = "us"; # Set console keymap

  # Key remapping via keyd. Targets ONLY the built-in laptop keyboard
  # (AT id 0001:0001); the Vial split (6401:45d4) is absent from `ids`, so
  # keyd ignores it and its firmware layout passes through untouched.
  # keyd is a superset of the old interception-tools/caps2esc setup:
  #   capslock = overload(control, esc)  == caps2esc -m 1 (tap=Esc, hold=Ctrl)
  # plus layers, which caps2esc could not do.
  services.keyd = {
    enable = true;
    keyboards.internal = {
      ids = [ "0001:0001" ];
      settings = {
        main = {
          # tap Caps -> Esc, hold Caps -> Ctrl (preserves prior muscle memory)
          capslock = "overload(control, esc)";
          # hold right-Alt -> extend layer; tap right-Alt stays a normal Alt tap
          rightalt = "layer(extend)";
          # keyd normalises right Shift to left Shift by default, which kills the
          # xkb `grp:shifts_toggle` layout switch (needs distinct L+R). Force keyd
          # to emit a real KEY_RIGHTSHIFT so both-shift toggle works again.
          rightshift = "rightshift";
        };
        # Combined extend layer (nav/symbol/num), mirroring the split's layer
        # logic. Starter set -- refine to match the layers designed in Vial.
        extend = {
          h = "left";
          j = "down";
          k = "up";
          l = "right";
          u = "home";
          o = "end";
          i = "pageup";
          m = "pagedown";
        };
      };
    };
  };
}
