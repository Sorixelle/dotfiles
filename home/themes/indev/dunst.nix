let colors = import ./colors.nix;
in config: pkgs: {
  enable = true;
  iconTheme = {
    inherit (config.gtk.iconTheme) name package;
    size = "64x64";
  };
  settings = {
    global = {
      follow = "keyboard";
      geometry = "512x3-0-0";
      shrink = true;
      padding = 16;
      horizontal_padding = 16;
      text_icon_padding = 16;
      frame_width = 10;
      frame_color = colors.blue;
      separator_color = "frame";
      separator_height = 10;
      font =
        "${config.srxl.fonts.ui.name} ${toString config.srxl.fonts.ui.size}";
      markup = "full";
      format = "<b>%a - %s</b>\\n%b";
      alignment = "right";
      show_age_threshold = "1m";
      word_wrap = true;
      icon_position = "right";
      browser = "${pkgs.firefox-bin}/bin/firefox";
    };
    urgency_low = {
      background = colors.bg;
      foreground = colors.fg;
      frame_color = colors.fgLight;
      timeout = 5;
    };
    urgency_normal = {
      background = colors.bg;
      foreground = colors.fg;
      timeout = 5;
    };
    urgency_critical = {
      background = colors.bg;
      foreground = colors.fg;
      frame_color = colors.red;
      timeout = 0;
    };
  };
}
