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
  };

  # Enable Bluetooth support
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Updates can leave Bluetooth rfkill soft-blocked; unblock at boot before
  # bluetoothd starts so the adapter is exposed to bluez.
  systemd.services.rfkill-unblock-bt = {
    description = "Unblock Bluetooth rfkill at boot";
    wantedBy = [ "multi-user.target" ];
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
