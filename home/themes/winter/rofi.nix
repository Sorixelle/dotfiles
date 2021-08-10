config:

let colors = import ./colors.nix;
in {
  enable = true;

  theme = let
    inherit (config.lib.formats.rasi) mkLiteral;
    background = mkLiteral colors.bg;
    foreground = mkLiteral colors.fg;
    foregroundLight = mkLiteral colors.fgLight;
    blue = mkLiteral colors.blue;
    grey = mkLiteral colors.blueLight;
  in {
    window = {
      background-color = background;
      padding = 16;
      border = 10;
      border-color = blue;
      font = "${config.srxl.fonts.ui.name} Light 12";

      location = mkLiteral "north";
      anchor = mkLiteral "north";
      y-offset = 200;
    };

    mainbox = { background-color = background; };

    inputbar = {
      background-color = grey;
      children = map mkLiteral [ "entry" ];
    };

    entry = {
      background-color = grey;
      text-color = foreground;
      font = "${config.srxl.fonts.ui.name} Light 24";
      padding = 16;
      placeholder = "Search...";
      placeholder-color = foregroundLight;
    };

    listview = {
      fixed-height = false;
      dynamic = true;
      scrollbar = false;
      cycle = false;
      lines = 15;
      margin = mkLiteral "16 0 0 0";
      background-color = background;
    };

    element = {
      padding = 4;
      background-color = background;
    };

    "element selected" = { background-color = grey; };

    element-text = {
      text-color = foreground;
      highlight = mkLiteral "underline ${colors.fg}";
    };
  };
}
