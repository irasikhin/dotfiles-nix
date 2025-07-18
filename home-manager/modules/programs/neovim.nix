# Fully declarative Neovim configuration
{ pkgs, ... }:

let
  # Tools previously managed by Mason
  toolPkgs = with pkgs; [
    # LSPs
    jdtls
    clangd
    nil-ls
    rust-analyzer
    kotlin-language-server
    metals # for scala
    jsonls
    # pyright # from example, add if needed for python
    # tsserver # from example, add if needed for typescript

    # Formatters
    black # python
    stylua
    shfmt
    nixfmt-rfc-style # better nix formatter

    # Linters
    shellcheck
    flake8

    # DAP
    java-debug-adapter
    java-test

    # Other tools for plugins
    fzf
    bat
  ];

  # All Neovim plugins, declared as Nix packages
  pluginPkgs = with pkgs.vimPlugins; [
    # Core
    lazy-nvim
    LazyVim

    # Colorschemes
    gruvbox-nvim
    darcula-dark-nvim
    onedark-nvim
    vscode-nvim
    darcula-solid-nvim
    github-nvim-theme

    # UI/UX
    fzf-lua # Replaces telescope
    which-key-nvim
    zen-mode-nvim

    # Mini plugins (packaged elegantly)
    (mini-nvim.withPlugins (p: [ p.files p.bufremove p.misc ]))

    # Utils & Dependencies
    plenary-nvim
    nvim-lspconfig
    nvim-treesitter.withAllGrammars # install all parsers at once, easier
    nvim-cmp
    cmp-nvim-lsp
    conform-nvim # for formatting

    # Dev plugins
    maven-nvim
    refactoring-nvim
    nvim-jdtls
    clangd_extensions-nvim
  ];

in
{
  programs.neovim = {
    enable = true;
    # Use the fresh neovim from the overlay
    package = pkgs.neovim;

    # Make all tools available ONLY inside neovim's PATH
    extraPackages = toolPkgs;

    # Declare all plugins for Nix to manage
    plugins = pluginPkgs;

    # Aliases
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
  };

  # Link your existing, but now cleaned, lua config
  xdg.configFile."nvim" = {
    source = ../../dotfiles/nvim; # Path to your nvim lua config
    recursive = true;
  };
}
