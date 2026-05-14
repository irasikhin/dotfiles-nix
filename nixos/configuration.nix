{
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./nvf.nix
    ./modules/networking.nix
    ./modules/locale.nix
    ./modules/display.nix
    ./modules/audio.nix
    ./modules/users.nix
    ./modules/packages.nix
  ];

  # Configure system bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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
    CPUWeight = 20;
    IOWeight = 20;
    MemoryHigh = "16G";
    MemoryMax = "22G";
  };

  # Disable printing support (CUPS)
  services.printing.enable = false;

  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.permittedInsecurePackages = [
    "python3.13-ecdsa-0.19.1"
  ];
}
