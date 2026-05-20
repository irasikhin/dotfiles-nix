{ ... }:

{
  imports = [
    ./core.nix
    ./lsp.nix
    ./ui.nix
    ./langs.nix
    ./keymaps.nix
  ];

  programs.nvf.enable = true;
}
