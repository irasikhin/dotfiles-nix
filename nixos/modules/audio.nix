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
          "hsp_hs"
          "hsp_ag"
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
          "lc3plus_h3"
        ];
        "bluez5.hfphsp-backend" = "native";
        "bluez5.autoswitch-profile" = true;
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

  # Disable built-in MediaTek BT adapter (Foxconn/Hon Hai 0489:e0cd);
  # external UGREEN BT6.0 (33fa:0012) is used instead.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0489", ATTR{idProduct}=="e0cd", ATTR{authorized}="0"
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
