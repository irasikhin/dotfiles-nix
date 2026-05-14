{
  config,
  pkgs,
  ...
}:

let
  homeDir = "/home/ir";
in
{
  imports = [
    ./modules/packages.nix
    ./modules/shell.nix
    ./modules/terminals.nix
    ./modules/services.nix
    ./modules/desktop.nix
  ];

  home.username = "ir";
  home.homeDirectory = homeDir;
  home.stateVersion = "22.11";
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
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
