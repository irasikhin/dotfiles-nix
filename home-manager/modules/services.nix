{
  config,
  pkgs,
  lib,
  ...
}:

let
  # sops-nix decrypts secrets here at activation (NixOS module).
  secretsDir = "/run/secrets";
  wallpaperPath = lib.makeBinPath [
    pkgs.coreutils
    pkgs.findutils
    pkgs.util-linux
    pkgs.procps
    pkgs.curl
    pkgs.jq
    pkgs.imagemagick
    pkgs.swaybg
  ];
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
      Environment = [ "PATH=${wallpaperPath}" ];
      ExecStart = "${pkgs.bash}/bin/bash ${config.xdg.configHome}/scripts/update_background_image.sh";
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
      EnvironmentFile = "${secretsDir}/proxy_9999";
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
      EnvironmentFile = "${secretsDir}/proxy_7777";
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

  systemd.user.services.kbd-lang-rgb = {
    Unit = {
      Description = "BCORNE RGB language indicator (en=cold white, ru=amber)";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Environment = [
        "PATH=${
          lib.makeBinPath [
            pkgs.sway
            pkgs.coreutils
          ]
        }"
      ];
      ExecStart = "${pkgs.python3}/bin/python3 ${config.xdg.configHome}/scripts/kbd_lang_rgb.py";
      Restart = "always";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  services.pueue.enable = true;
  services.syncthing.enable = true;

  systemd.user.services.gost-8888 = {
    Unit = {
      Description = "GOST proxy forwarder on port 8888";
      After = [ "network-online.target" ];
    };
    Service = {
      EnvironmentFile = "${secretsDir}/proxy_8888";
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
