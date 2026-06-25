{
  pkgs,
  inputs,
  config,
  ...
}:

let
  homeDir = config.users.users.ir.home;
in
{
  # Enable Firefox browser
  programs.firefox.enable = true;

  # Enable GnuPG agent with SSH support
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Enable OpenSSH daemon for remote access
  services.openssh.enable = true;

  # udev rules for QMK/Vial keyboards (HID raw access without root)
  hardware.keyboard.qmk.enable = true;

  # Enable Docker with Btrfs storage driver
  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "btrfs";
  virtualisation.docker.daemon.settings = {
    "data-root" = "${homeDir}/.docker-data";
    "default-address-pools" = [
      {
        "base" = "192.170.0.0/16";
        "size" = 24;
      }
    ];
    # Public Docker Hub mirrors (fallback when registry-1.docker.io unreachable)
    "registry-mirrors" = [
      "https://mirror.gcr.io"
      "https://dockerhub.timeweb.cloud"
      "https://huecker.io"
    ];
  };

  # Podman: mirror docker.io through same public mirrors via registries.conf
  virtualisation.containers.registries.search = [ "docker.io" ];
  environment.etc."containers/registries.conf.d/00-mirrors.conf".text = ''
    [[registry]]
    prefix = "docker.io"
    location = "registry-1.docker.io"

    [[registry.mirror]]
    location = "mirror.gcr.io"

    [[registry.mirror]]
    location = "dockerhub.timeweb.cloud"

    [[registry.mirror]]
    location = "huecker.io"
  '';

  # Install essential system packages
  environment.systemPackages = with pkgs; [
    vial
    docker-compose
    freefilesync
    strongswan
    strongswanNM
    openssl
    python312Packages.pip-system-certs
    python312Packages.click
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
    python312Packages.psycopg2
    home-manager
    git
    ntfs3g
    coreutils
    bc
    clojure
    leiningen
    babashka
    maven
    gradle
    cargo
    rustc
    rustfmt
    clippy
    nodejs
    typescript
    prettier
    eslint
    google-java-format
    zulu25
    net-tools
    fastfetch
    bubblewrap
    shadowsocks-rust
    brave
    floorp-bin
    firejail
    monero-cli
    monero-gui
    inputs.burl.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.sandboxer.packages.${pkgs.stdenv.hostPlatform.system}.default
    mtr
  ];

  # Enable Nix-ld (to run non-NixOS binaries)
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [ ];

  # Enable VirtualBox support
  virtualisation.virtualbox.host.enable = false;

  # Java configuration
  programs.java = {
    enable = true;
    package = pkgs.zulu25;
  };
}
