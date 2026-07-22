{
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./nvf
    ./modules/networking.nix
    ./modules/locale.nix
    ./modules/display.nix
    ./modules/audio.nix
    ./modules/users.nix
    ./modules/packages.nix
    ./modules/secrets.nix
    ./modules/security.nix
    ./modules/mesh.nix
  ];

  # Configure system bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Pretty boot splash
  boot.plymouth = {
    enable = true;
    themePackages = [ (pkgs.callPackage ./plymouth-theme { }) ];
    theme = "cosmos";
  };

  # Silent kernel/userspace boot so Plymouth is not overdrawn by text
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
  boot.kernelParams = [
    "btusb.enable_autosuspend=0"
    "quiet"
    "splash"
    "loglevel=3"
    "rd.systemd.show_status=auto"
    "rd.udev.log_level=3"
    "vt.global_cursor_default=0"
  ];

  boot.kernel.sysctl."fs.inotify.max_queued_events" = 1048576;

  # Set system state version (important for maintaining compatibility)
  system.stateVersion = "24.05";

  # Enable Nix Flakes
  nix.package = pkgs.nixVersions.stable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Limit build parallelism so `nh switch` does not freeze the laptop.
  # 4 parallel derivations × 4 cores each, total CPU ~16 threads cap.
  nix.settings = {
    max-jobs = 4;
    cores = 4;
  };

  # Throttle nix-daemon via cgroups: low CPU/IO priority, memory cap.
  systemd.services.nix-daemon.serviceConfig = {
    CPUWeight = 50;
    IOWeight = 50;
    MemoryHigh = "16G";
    MemoryMax = "22G";
  };

  # Disable printing support (CUPS)
  services.printing.enable = false;

  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.permittedInsecurePackages = [
    "python3.13-ecdsa-0.19.2"
  ];
}
