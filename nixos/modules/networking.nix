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
}
