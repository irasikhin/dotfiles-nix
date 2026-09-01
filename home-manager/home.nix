{
  config,
  ...
}:

{
  imports = [
    ./modules/packages.nix
    ./modules/shell.nix
    ./modules/terminals.nix
    ./modules/services.nix
    ./modules/desktop.nix
    ./modules/pi.nix
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

  programs.ghostty = {
    enable = false;
  };
}
