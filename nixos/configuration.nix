{
  config,
  pkgs,
  # Accept 'inputs' here to access the overlay
  inputs,
  lib,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Add the overlay to the system's package set.
  # This is the idiomatic way to do it for NixOS.
  nixpkgs.overlays = [
    inputs.neovim-nightly-overlay.overlays.default
  ];


  # --- The rest of your configuration remains unchanged ---

  # Configure system bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set hostname and networking settings
  networking.hostName = "irnixos";
  networking.wireless.enable = false; # Disable wireless networking (will use NetworkManager)

  services.resolved = {
    enable = false;
    domains = [ "~." ];
  };
  networking.networkmanager = {
    enable = true;
    enableStrongSwan = true;
  };

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

  # Enable X server and configure display manager/window manager
  services.xserver.enable = true;
  services.xserver.desktopManager.xfce.enable = false;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.lightdm.greeters.gtk = {
    extraConfig = ''
      user-background = false
    '';
  };
  services.displayManager.defaultSession = "none+i3"; # Use i3 as window manager
  services.xserver.windowManager.i3 = {
    enable = true;
    extraPackages = with pkgs; [
      rofi # Application launcher
      i3status-rust # Status bar for i3
      i3lock-color # Lock screen
      i3lock-fancy # Fancier lock screen
    ];
  };
  services.xserver.xkb = {
    layout = "us,ru"; # Enable US and Russian keyboard layouts
    options = "grp:shifts_toggle"; # Toggle layout using both shift keys
  };

  console.keyMap = "us"; # Set console keymap

  # Disable printing support (CUPS)
  services.printing.enable = false;

  # Enable audio using PipeWire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable Firefox browser
  programs.firefox.enable = true;

  # Enable GnuPG agent with SSH support
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Enable OpenSSH daemon for remote access
  services.openssh.enable = true;

  # Set system state version (important for maintaining compatibility)
  system.stateVersion = "24.05";

  # Enable Nix Flakes
  nix.package = pkgs.nixVersions.stable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Configure user account
  users.users.irasikhin = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "audio"
      "qemu-libvirtd"
      "docker"
      "libvirtd"
    ];
    packages = with pkgs; [ ];
    shell = pkgs.zsh; # Set default shell to Zsh
  };
  programs.zsh.enable = true;
  programs.tmux = {
    enable = true;
    clock24 = true;
  };

  # Enable key remapping (Caps Lock to Escape)
  services.interception-tools = {
    enable = true;
    plugins = with pkgs; [
      interception-tools-plugins.caps2esc
    ];
    udevmonConfig = ''
      - JOB: "${pkgs.interception-tools}/bin/intercept -g $DEVNODE | ${pkgs.interception-tools-plugins.caps2esc}/bin/caps2esc -m 1 | ${pkgs.interception-tools}/bin/uinput -d $DEVNODE"
        DEVICE:
          EVENTS:
            EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
    '';
  };

  # Set environment variables
  environment.variables = {
    GDK_SCALE = "1";
    GDK_DPI_SCALE = "1.5";
  };

  # Enable light control program
  programs.light.enable = true;

  # Enable Docker with Btrfs storage driver
  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "btrfs";
  virtualisation.docker.daemon.settings = {
    "data-root" = "/home/irasikhin/.docker-data";
    "default-address-pools" = [
      {
        "base" = "192.170.0.0/16";
        "size" = 24;
      }
    ];
  };

  # Install essential system packages
  environment.systemPackages = with pkgs; [
    docker-compose
    freefilesync
    strongswan
    strongswanNM
    openssl
    python312Packages.pip-system-certs
    libvirt
    vagrant
    wireguard-tools
    tinyproxy
    xvfb-run
    swt
    distrobox
    dive
    podman-tui
    autoconf
    gnumake
    graphviz
    pandoc
    file
    gcc
    alsa-lib
    autossh
    clang
    clang-tools
  ];

  # Enable firewall
  networking.firewall.enable = true;

  # Enable Nix-ld (to run non-NixOS binaries)
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [ ];

  # Enable Bluetooth support
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Allow users in wheel group to execute sudo commands without password
  security.sudo.wheelNeedsPassword = false;

  # Enable VirtualBox support
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "irasikhin" ];

  nixpkgs.config.allowUnfree = true;

  # This should be fine here.
  nixpkgs.config.packageOverrides = pkgs: {
    vagrant = pkgs.vagrant.override { withLibvirt = false; };
  };

  # Enable TinyProxy
  services.tinyproxy = {
    enable = true;
    settings = {
      Port = 8888;
      Listen = "127.0.0.1";
      Timeout = 600;
      Allow = "127.0.0.1";
      Upstream = "socks5 127.0.0.1:1337";
    };
  };

  # Enable Java (Temurin JDK 21)
  programs.java = {
    enable = true;
    package = pkgs.temurin-bin-21;
  };

  swapDevices = lib.mkForce [ ];
}
