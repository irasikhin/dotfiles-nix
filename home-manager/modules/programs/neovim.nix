# Fully declarative Neovim configuration
{ pkgs, ... }:

let
  toolPkgs = with pkgs; [
    jdtls clangd nil-ls rust-analyzer kotlin-language-server metals jsonls
    black stylua shfmt nixfmt-rfc-style shellcheck flake8 java-debug-adapter
    java-test fzf bat
  ];

  pluginPkgs = with pkgs.vimPlugins; [
    lazy-nvim LazyVim gruvbox-nvim darcula-dark-nvim onedark-nvim vscode-nvim
    darcula-solid-nvim github-nvim-theme fzf-lua which-key-nvim zen-mode-nvim
    (mini-nvim.withPlugins (p: [ p.files p.bufremove p.misc ]))
    plenary-nvim nvim-lspconfig nvim-treesitter.withAllGrammars nvim-cmp
    cmp-nvim-lsp conform-nvim maven-nvim refactoring-nvim nvim-jdtls
    clangd_extensions-nvim
  ];

in
{
  programs.neovim = {
    enable = true;
    package = pkgs.neovim;
    extraPackages = toolPkgs;
    plugins = pluginPkgs;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
  };

  xdg.configFile."nvim" = {
    source = ../../dotfiles/nvim;
    recursive = true;
  };
}
