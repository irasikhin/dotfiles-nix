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
  # It's a good practice to update stateVersion to the current release
  home.stateVersion = "24.05";

  # Global session variables
  home.sessionVariables = { EDITOR = "nvim"; };

  # Allow proprietary software
  nixpkgs.config.allowUnfree = true;

  # Enable home-manager itself
  programs.home-manager.enable = true;
}
