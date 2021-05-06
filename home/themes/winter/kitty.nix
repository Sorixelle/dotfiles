config:

let
  colors = import ./colors.nix;
in {
  enable = true;
  font.name = config.srxl.fonts.monospace.name;
  settings = {
    enable_audio_bell = false;
    scrollback_lines = 20000;
    window_padding_width = 16;

    background = colors.bg;
    foreground = colors.fg;
    selection_background = colors.fg;
    selection_foreground = colors.bg;
    url_color = colors.blue;
    cursor = colors.fg;

    color0 = colors.bg;
    color1 = colors.red;
    color2 = colors.teal;
    color3 = colors.redLight;
    color4 = colors.blueDark;
    color5 = colors.redDark;
    color6 = colors.blue;
    color7 = colors.fg;

    color8 = colors.blueLight;
    color9 = colors.red;
    color10 = colors.teal;
    color11 = colors.redLight;
    color12 = colors.blueDark;
    color13 = colors.redDark;
    color14 = colors.blue;
    color15 = colors.fg;
  };
}
