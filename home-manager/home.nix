{
  config,
  lib,
  ...
}:

{
  imports = [
    ./modules/packages.nix
    ./modules/shell.nix
    ./modules/terminals.nix
    ./modules/services.nix
    ./modules/desktop.nix
  ];

  home.username = "ir";
  home.homeDirectory = "/home/ir";
  home.stateVersion = "22.11";

  # Skip Neovim's OSC 11 terminal-background query (mis-proxied by some
  # multiplexers, causes slow startup and leaked "11;rgb:..." escapes). nvim reads
  # COLORFGBG instead: light fg / dark bg.
  home.sessionVariables.COLORFGBG = "15;0";
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
      # checkov pulls python ecdsa transitively; CVE-2024-23342 (Minerva
      # timing side-channel) is irrelevant for a local IaC scanner.
      permittedInsecurePackages = [
        "python3.13-ecdsa-0.19.2"
      ];
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  news.display = "silent";

  home.file."${config.xdg.configHome}" = {
    source = ./dotfiles;
    recursive = true;
  };
  home.file.".ideavimrc".source = ./ideavimrc;

  # Disable bundled Code With Me plugin (broken descriptor in nix-repacked IDEA).
  # Appends to disabled_plugins.txt non-destructively for every installed IDEA
  # version; IDE UI still manages the file. Version-agnostic.
  home.activation.disableCodeWithMe = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    for d in "${config.xdg.configHome}/JetBrains"/IntelliJIdea*; do
      [ -d "$d" ] || continue
      f="$d/disabled_plugins.txt"
      [ -e "$f" ] || touch "$f"
      if ! grep -qxF "com.jetbrains.remoteDevelopment" "$f"; then
        echo "com.jetbrains.remoteDevelopment" >> "$f"
      fi
    done
  '';
  programs.ghostty = {
    enable = false;
  };
}
