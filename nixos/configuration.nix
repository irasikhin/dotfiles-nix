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
  # This is the idiomatic way to fix the `_module.args.pkgs` error.
  nixpkgs.overlays = [
    inputs.neovim-nightly-overlay.overlays.default
  ];


  # --- The rest of your configuration remains unchanged ---

  # Configure system bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set hostname and networking settings
  networking.hostName = "irnixos";
  networking.wireless.enable = false;

  services.resolved = {
    enable = false;
    domains = [ "~." ];
  };
  networking.networkmanager = {
    enable = true;
    enableStrongSwan = true;
  };

  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Moscow";

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

  services.xserver.enable = true;
  services.xserver.desktopManager.xfce.enable = false;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.lightdm.greeters.gtk.extraConfig = "user-background = false";
  services.displayManager.defaultSession = "none+i3";
  services.xserver.windowManager.i3 = {
    enable = true;
    extraPackages = with pkgs; [ rofi i3status-rust i3lock-color i3lock-fancy ];
  };
  services.xserver.xkb = {
    layout = "us,ru";
    options = "grp:shifts_toggle";
  };

  console.keyMap = "us";
  services.printing.enable = false;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs.firefox.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.openssh.enable = true;
  system.stateVersion = "24.05";
  nix.package = pkgs.nixVersions.stable;
  nix.extraOptions = "experimental-features = nix-command flakes";

  users.users.irasikhin = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "qemu-libvirtd" "docker" "libvirtd" ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;
  programs.tmux = {
    enable = true;
    clock24 = true;
  };

  services.interception-tools = {
    enable = true;
    plugins = [ pkgs.interception-tools-plugins.caps2esc ];
    udevmonConfig = ''
      - JOB: "${pkgs.interception-tools}/bin/intercept -g $DEVNODE | ${pkgs.interception-tools-plugins.caps2esc}/bin/caps2esc -m 1 | ${pkgs.interception-tools}/bin/uinput -d $DEVNODE"
        DEVICE:
          EVENTS:
            EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
    '';
  };

  environment.variables = { GDK_SCALE = "1"; GDK_DPI_SCALE = "1.5"; };
  programs.light.enable = true;
  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
    daemon.settings = {
      "data-root" = "/home/irasikhin/.docker-data";
      "default-address-pools" = [{ base = "192.170.0.0/16"; size = 24; }];
    };
  };

  environment.systemPackages = with pkgs; [
    docker-compose freefilesync strongswan strongswanNM openssl
    python312Packages.pip-system-certs libvirt vagrant wireguard-tools
    tinyproxy xvfb-run swt distrobox dive podman-tui autoconf gnumake
    graphviz pandoc file gcc alsa-lib autossh clang clang-tools
  ];

  networking.firewall.enable = true;
  programs.nix-ld.enable = true;
  hardware.bluetooth = { enable = true; powerOnBoot = true; };
  services.blueman.enable = true;
  security.sudo.wheelNeedsPassword = false;
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "irasikhin" ];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.packageOverrides = pkgs: {
    vagrant = pkgs.vagrant.override { withLibvirt = false; };
  };

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

  programs.java = {
    enable = true;
    package = pkgs.temurin-bin-21;
  };

  swapDevices = lib.mkForce [ ];
}
