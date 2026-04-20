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

  # Disable printing support (CUPS)
  services.printing.enable = false;

  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.permittedInsecurePackages = [
    "python3.13-ecdsa-0.19.1"
  ];
}
