# This is the main entrypoint for home-manager configuration.
# It imports all other modules.
{ ... }: {
  imports = [
    ./modules/cli.nix
    ./modules/gui.nix
    ./modules/shells.nix
    ./modules/programs/neovim.nix
    ./modules/programs/i3.nix
  ];

  # Basic user settings
  home.username = "irasikhin";
  home.homeDirectory = "/home/irasikhin";
  home.stateVersion = "24.05";

  home.sessionVariables = { EDITOR = "nvim"; };

  nixpkgs.config.allowUnfree = true;

  programs.home-manager.enable = true;
}
