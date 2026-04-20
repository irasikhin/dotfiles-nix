{ config, pkgs, ... }:

let
  homeDir = "/home/ir";
  repoDir = "${homeDir}/dotfiles-nix";
  secretsDir = "${repoDir}/secrets";
in
{
  systemd.user.services.autossh-runner = {
    Unit = {
      Description = "AutoSSH SOCKS tunnel (runner)";
      After = [ "network-online.target" ];
    };

    Service = {
      ExecStart = ''
        ${pkgs.autossh}/bin/autossh \
          -M 0 \
          -N \
          -D 1337 \
          runner
      '';
      Restart = "always";
      RestartSec = 5;
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  systemd.user.services.wallpaper-rotator = {
    Unit = {
      Description = "Wallpaper rotator";
      After = [ "network-online.target" ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${config.xdg.configHome}/scripts/update_background_image.sh";
    };
  };

  systemd.user.timers.wallpaper-rotator = {
    Unit = {
      Description = "Rotate wallpapers every hour";
    };

    Timer = {
      OnStartupSec = "1h";
      OnUnitActiveSec = "1h";
      Persistent = true;
      Unit = "wallpaper-rotator.service";
    };

    Install = {
      WantedBy = [ "timers.target" ];
    };
  };

  systemd.user.services.gost-9999 = {
    Unit = {
      Description = "GOST proxy forwarder on port 9999";
      After = [ "network-online.target" ];
    };
    Service = {
      EnvironmentFile = "${secretsDir}/proxy-9999.env";
      ExecStart = pkgs.writeShellScript "gost-9999" ''
        exec ${pkgs.gost}/bin/gost -L :9999 -F "$PROXY_UPSTREAM"
      '';
      Restart = "always";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  systemd.user.services.gost-7777 = {
    Unit = {
      Description = "GOST proxy forwarder on port 7777";
      After = [ "network-online.target" ];
    };
    Service = {
      EnvironmentFile = "${secretsDir}/proxy-7777.env";
      ExecStart = pkgs.writeShellScript "gost-7777" ''
        exec ${pkgs.gost}/bin/gost -L :7777 -F "$PROXY_UPSTREAM"
      '';
      Restart = "always";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  systemd.user.services.gost-8888 = {
    Unit = {
      Description = "GOST proxy forwarder on port 8888";
      After = [ "network-online.target" ];
    };
    Service = {
      EnvironmentFile = "${secretsDir}/proxy-8888.env";
      ExecStart = pkgs.writeShellScript "gost-8888" ''
        exec ${pkgs.gost}/bin/gost -L :8888 -F "$PROXY_UPSTREAM"
      '';
      Restart = "always";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
