{ pkgs, ... }:

{
  # Set hostname and networking settings
  networking.hostName = "irnixos";

  services.resolved = {
    enable = true;
    settings.Resolve.Domains = [ "~." ];
  };
  networking.networkmanager = {
    enable = true;
    plugins = [
      pkgs.networkmanager-strongswan
      pkgs.networkmanager-openconnect
    ];
  };

  # Enable firewall
  networking.firewall.enable = true;

  # Allow containers to reach the host gost proxy (9999) via host.docker.internal.
  # Scoped to docker bridge interfaces only (docker0 + br-*); NOT exposed on tailscale0/wan.
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -i docker0 -p tcp --dport 9999 -j nixos-fw-accept
    iptables -A nixos-fw -i br-+ -p tcp --dport 9999 -j nixos-fw-accept
  '';

  # V2Ray proxy
  services.v2raya.enable = true;
  services.v2raya.cliPackage = pkgs.xray;

  # Route nix-daemon fetches through v2raya by default. GitHub source tarballs
  # and the NixOS binary cache + mirrors are reachable directly and bypass the
  # proxy. JetBrains is deliberately NOT bypassed: its CDN is geo-blocked in RU,
  # so IntelliJ IDEA must download through the proxy.
  systemd.services.nix-daemon.environment = {
    https_proxy = "http://127.0.0.1:9999";
    http_proxy = "http://127.0.0.1:9999";
    all_proxy = "http://127.0.0.1:9999";
    no_proxy = "github.com,githubusercontent.com,github.io,nixos.org,cache.nixos.org,mirror.sjtu.edu.cn,mirrors.ustc.edu.cn,mirrors.cernet.edu.cn";
  };

  # Tailscale
  services.tailscale.enable = true;
}
