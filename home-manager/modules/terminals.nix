{ pkgs, ... }:

{
  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
    attachExistingSession = true;
    exitShellOnExit = true;
    settings = {
      theme = "gruvbox";
      pane_frames = false;
    };
    themes.gruvbox = ''
      themes {
        gruvbox {
          fg 212 190 152
          bg 29 32 33
          black 40 40 40
          red 234 105 98
          green 169 182 101
          yellow 216 166 87
          blue 125 174 163
          magenta 211 134 155
          orange 231 138 78
          cyan 137 180 130
          white 168 153 132
        }
      }
    '';
  };

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "FiraCode Nerd Font:size=18";
        shell = "${pkgs.zsh}/bin/zsh";
      };
      colors-dark = {
        background = "1d2021";
        foreground = "d4be98";
        regular0 = "1d2021";
        regular1 = "ea6962";
        regular2 = "a9b665";
        regular3 = "d8a657";
        regular4 = "7daea3";
        regular5 = "d3869b";
        regular6 = "89b482";
        regular7 = "a89984";
        bright0 = "928374";
        bright1 = "ea6962";
        bright2 = "a9b665";
        bright3 = "d8a657";
        bright4 = "7daea3";
        bright5 = "d3869b";
        bright6 = "89b482";
        bright7 = "d4be98";
      };
    };
  };
}
