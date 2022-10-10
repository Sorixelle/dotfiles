{ config, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        padding = {
          x = 20;
          y = 20;
        };
        opacity = 0.75;
      };
      font = {
        normal = {
          family = config.srxl.fonts.monospace.name;
          style = "Italic";
        };
        bold.style = "Bold Italic";
        size = config.srxl.fonts.monospace.size;
      };
      colors = {
        primary = {
          background = "#121E1D";
          foreground = "#DFE4F3";
        };
        normal = {
          black = "#0D0D0D";
          red = "#5B4744";
          green = "#3B6E27";
          yellow = "#638A15";
          blue = "#266E3D";
          magenta = "#554F52";
          cyan = "#316068";
          white = "#B8C0CA";
        };
        bright = {
          black = "#0D0D0D";
          red = "#5B4744";
          green = "#3B6E27";
          yellow = "#638A15";
          blue = "#266E3D";
          magenta = "#554F52";
          cyan = "#316068";
          white = "#B8C0CA";
        };
      };
    };
  };
}
