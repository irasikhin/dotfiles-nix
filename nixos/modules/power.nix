{
  services.tlp.settings = {
    PLATFORM_PROFILE_ON_AC = "balanced";
    CPU_ENERGY_PERF_POLICY_ON_AC = "balance_power";

    # Never USB-autosuspend the Bluetooth radios: runtime-suspended they hang
    # (HCI_Reset times out, the adapter then refuses to power on until it is
    # power-cycled). `btusb.enable_autosuspend=0` is not enough, TLP writes
    # power/control=auto back onto the device. A denylist entry forces "on".
    #
    # The MediaTek MT7961 (0489:e0cd) has to be listed by ID: it is an IAD
    # combo device with class "ef", so USB_EXCLUDE_BTUSB (which matches
    # Bluetooth radios by class e0/01/01) does not cover it.
    USB_DENYLIST = "0bda:a760 0489:e0cd";

    # Belt and braces for any other USB Bluetooth radio.
    USB_EXCLUDE_BTUSB = 1;
  };
}
