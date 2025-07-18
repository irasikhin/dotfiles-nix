# Manages Graphical User Interface applications
{ pkgs, ... }: {
  home.packages = with pkgs; [
    # Terminals
    alacritty
    kitty

    # Fonts
    pango
    fira-code
    (nerd-fonts.override { fonts = [ "FiraCode" ]; })
    font-awesome

    # Browsers
    librewolf
    floorp
    ungoogled-chromium

    # System tools & utilities
    pass # password-store
    xclip
    brillo
    networkmanagerapplet
    openconnect
    networkmanager-openconnect
    networkmanager-vpnc
    autorandr
    xlayoutdisplay
    inkscape
    gimp
    jmeter
    libreoffice

    # Applications
    telegram-desktop
    (jetbrains.idea-community.override {
      plugins = with pkgs.jetbrains; [ ]; # Add plugins here if needed
    })
    spotify
    vscode
    zoom-us
    obsidian
    insomnia
    httpie-desktop
    bruno
    yandex-disk
    yandex-music
    # cointop # This is a TUI, fits better in cli.nix maybe, but ok here.
  ];

  # Your Alacritty config.
  # For more complex configs, consider using `home.file`
  programs.alacritty.settings = {
    font = {
      size = 12.0;
      normal = { family = "FiraCode Nerd Font"; style = "Regular"; };
      bold = { family = "FiraCode Nerd Font"; style = "Bold"; };
      italic = { family = "FiraCode Nerd Font"; style = "Italic"; };
    };
  };
}
