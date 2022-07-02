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
        opacity = 0.9;
      };
      font = {
        normal.family = config.srxl.fonts.monospace.name;
        size = config.srxl.fonts.monospace.size;
      };
      colors = {
        primary = {
          background = "#2A2522";
          foreground = "#F3E4DF";
        };
        normal = {
          black = "#2A2522";
          red = "#7A5C55";
          green = "#535D40";
          yellow = "#A89159";
          blue = "#47485B";
          magenta = "#5B4187";
          cyan = "#675391";
          white = "#D8CAC6";
        };
        bright = {
          black = "#5D4D4D";
          red = "#A38678";
          green = "#6E7C62";
          yellow = "#D8BB73";
          blue = "#6E708D";
          magenta = "#835EC2";
          cyan = "#917DB1";
          white = "#F3E4DF";
        };
      };
    };
  };
}
