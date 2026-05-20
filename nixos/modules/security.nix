{ pkgs, ... }:

{
  # ---- Disk health ----------------------------------------------------------
  # SMART monitoring; emails on failure (configure mailto if you wire mail).
  services.smartd = {
    enable = true;
    autodetect = true;
  };

  # ---- Sandboxed browsers ---------------------------------------------------
  # `firefox`, `brave`, `google-chrome-stable` in PATH go through firejail.
  programs.firejail = {
    enable = true;
    wrappedBinaries = {
      firefox = {
        executable = "${pkgs.firefox}/bin/firefox";
        profile = "${pkgs.firejail}/etc/firejail/firefox.profile";
      };
      floorp = {
        executable = "${pkgs.floorp-bin}/bin/floorp";
        profile = "${pkgs.firejail}/etc/firejail/firefox.profile";
      };
      brave = {
        executable = "${pkgs.brave}/bin/brave";
        profile = "${pkgs.firejail}/etc/firejail/brave.profile";
      };
      google-chrome-stable = {
        executable = "${pkgs.google-chrome}/bin/google-chrome-stable";
        profile = "${pkgs.firejail}/etc/firejail/google-chrome.profile";
      };
    };
  };

  # ---- sudo lockdown --------------------------------------------------------
  # Only wheel members may execute the sudo binary at all.
  security.sudo.execWheelOnly = true;

  # ---- Nix daemon trust -----------------------------------------------------
  # Restrict who can push to the daemon (impacts substituters, sandboxing).
  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];
}
