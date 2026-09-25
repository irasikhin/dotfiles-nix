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

  # Tailscale
  services.tailscale.enable = true;
}
