{ pkgs, ... }:

{
  # Set hostname and networking settings
  networking.hostName = "irnixos";

  services.resolved = {
    enable = false;
    domains = [ "~." ];
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

  # V2Ray proxy
  services.v2raya.enable = true;
  services.v2raya.cliPackage = pkgs.xray;

  # Route nix-daemon fetches through v2raya (JetBrains/GitHub release CDNs geo-blocked in RU)
  systemd.services.nix-daemon.environment = {
    https_proxy = "http://127.0.0.1:9999";
    http_proxy = "http://127.0.0.1:9999";
    all_proxy = "http://127.0.0.1:9999";
  };

  # Tailscale
  services.tailscale.enable = true;
}
