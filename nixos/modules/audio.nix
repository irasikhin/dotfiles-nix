{ pkgs, lib, ... }:

{
  # Enable audio using PipeWire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.extraConfig.bluetoothEnhancements = {
      "monitor.bluez.properties" = {
        "bluez5.enable-sbc-xq" = true;
        "bluez5.enable-msbc" = true;
        "bluez5.enable-hw-volume" = true;
        "bluez5.roles" = [
          "hfp_hf"
          "hfp_ag"
          "a2dp_sink"
          "a2dp_source"
        ];
        "bluez5.codecs" = [
          "sbc"
          "sbc_xq"
          "aac"
          "ldac"
          "msbc"
        ];
        "bluez5.hfphsp-backend" = "native";
        "bluez5.autoswitch-profile" = true;
      };

      # WirePlumber remembers "headset mode" (HFP) and restores it whenever the
      # device connects. When that happens while the A2DP profile is no longer
      # in the card, it deadlocks — "Could not find valid non-headset profile,
      # not switching" — and the headset stays connected but silent until it is
      # reconnected. The headset profile is still entered on demand while
      # recording (bluetooth.autoswitch-to-headset-profile).
      "wireplumber.settings" = {
        "bluetooth.use-persistent-storage" = false;
      };
    };
  };

  # Enable Bluetooth support
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.bluetooth.settings = {
    General = {
      Experimental = true;
      KernelExperimental = true;
      ControllerMode = "dual";
      FastConnectable = "true";
      JustWorksRepairing = "always";
    };
  };
  services.blueman.enable = true;

  # Prefer the built-in MediaTek MT7961 BT adapter (0489:e0cd) over the external
  # Realtek RTL8761BU dongle (0bda:a760). The dongle is a flaky clone: it wedges
  # under load, emits truncated HCI events ("unexpected cc 0x0c2d length: 3 < 4"),
  # fails profile connects with "Function not implemented (38)" and never
  # persists link keys, so headsets have to re-pair on every reconnect.
  # Swap which adapter is disabled here to go back to the dongle.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", ATTR{idProduct}=="a760", ATTR{authorized}="0"

    # A newly appearing Bluetooth rfkill (ideapad EC state on boot, or a fresh
    # HCI device) comes up soft-blocked, and a soft-blocked adapter cannot be
    # powered on by BlueZ. Unblock it as soon as it shows up.
    ACTION=="add", SUBSYSTEM=="rfkill", ATTR{type}=="bluetooth", RUN+="${pkgs.util-linux}/bin/rfkill unblock bluetooth"
  '';

  # Updates can leave Bluetooth rfkill soft-blocked; unblock at boot before
  # bluetoothd starts so the adapter is exposed to bluez.
  systemd.services.rfkill-unblock-bt = {
    description = "Unblock Bluetooth rfkill at boot and after resume";
    wantedBy = [
      "multi-user.target"
      "suspend.target"
      "hibernate.target"
      "hybrid-sleep.target"
    ];
    after = [
      "suspend.target"
      "hibernate.target"
      "hybrid-sleep.target"
    ];
    before = [ "bluetooth.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.util-linux}/bin/rfkill unblock bluetooth";
    };
  };

  # Workaround: blueman 2.4.6 ships its own user unit while services.blueman
  # also defines ExecStart, producing a duplicate ExecStart= that systemd
  # refuses. Clear it first, then set the single intended command.
  systemd.user.services.blueman-applet.serviceConfig.ExecStart = lib.mkForce [
    ""
    "${pkgs.blueman}/bin/blueman-applet"
  ];
}
