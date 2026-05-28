{ config, pkgs, ... }:

{
  sops.secrets = {
    yggdrasil_private_key = { };
    yggdrasil_peer = { };
    yggdrasil_allowed_pubkey = { };
  };

  sops.templates."yggdrasil.conf" = {
    content = ''
      {
        "PrivateKeyPath": "${config.sops.secrets.yggdrasil_private_key.path}",
        "Peers": ["${config.sops.placeholder.yggdrasil_peer}"],
        "AllowedPublicKeys": ["${config.sops.placeholder.yggdrasil_allowed_pubkey}"],
        "IfName": "ygg0",
        "Listen": [],
        "MulticastInterfaces": []
      }
    '';
  };

  environment.systemPackages = [ pkgs.yggdrasil ];

  systemd.services.yggdrasil = {
    description = "Yggdrasil mesh";
    after = [
      "network-pre.target"
      "sops-install-secrets.service"
    ];
    wants = [ "network.target" ];
    before = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.yggdrasil}/bin/yggdrasil -useconffile ${
        config.sops.templates."yggdrasil.conf".path
      }";
      ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
      Restart = "always";
      RuntimeDirectory = "yggdrasil";
      RuntimeDirectoryMode = "0750";
      AmbientCapabilities = "CAP_NET_ADMIN CAP_NET_BIND_SERVICE";
      CapabilityBoundingSet = "CAP_NET_ADMIN CAP_NET_BIND_SERVICE";
      ProtectHome = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6 AF_NETLINK";
      RestrictNamespaces = true;
    };
  };
}
