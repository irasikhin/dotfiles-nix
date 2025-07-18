# Manages Graphical User Interface applications
{ pkgs, ... }: {
  home.packages = with pkgs; [
    alacritty kitty pango fira-code (nerd-fonts.override { fonts = [ "FiraCode" ]; })
    font-awesome librewolf floorp ungoogled-chromium pass xclip brillo
    networkmanagerapplet openconnect networkmanager-openconnect networkmanager-vpnc
    autorandr xlayoutdisplay inkscape gimp jmeter libreoffice telegram-desktop
    (jetbrains.idea-community.override { plugins = []; })
    spotify vscode zoom-us obsidian insomnia httpie-desktop bruno yandex-disk yandex-music
  ];

  programs.alacritty.settings = {
    font = {
      size = 12.0;
      normal = { family = "FiraCode Nerd Font"; style = "Regular"; };
      bold = { family = "FiraCode Nerd Font"; style = "Bold"; };
      italic = { family = "FiraCode Nerd Font"; style = "Italic"; };
    };
  };
}
