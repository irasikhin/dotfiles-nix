{ ... }:

{
  imports = [
    ./core.nix
    ./lsp.nix
    ./ui.nix
    ./langs.nix
    ./keymaps.nix
    ./extras.nix
  ];

  programs.nvf.enable = true;
}
