{ pkgs, ... }:

let
  homeDir = "/home/ir";
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
  };

  # Install essential system packages
  environment.systemPackages = with pkgs; [
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
    claude-code
    tmux
    bubblewrap
    shadowsocks-rust
    brave
    firejail
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
