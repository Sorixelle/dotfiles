{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.dunst = {
    enable = true;
    iconTheme = {
      inherit (config.gtk.iconTheme) name package;
      size = "64x64";
    };
    settings = {
      global = {
        follow = "keyboard";
        width = "(200, 512)";
        height = 128;
        origin = "top-right";
        offset = "0x0";
        notification_limit = 6;
        padding = 8;
        horizontal_padding = 8;
        text_icon_padding = 8;
        frame_width = 4;
        separator_color = "frame";
        separator_height = 4;
        font = "${config.srxl.fonts.ui.name} ${toString config.srxl.fonts.ui.size}";
        markup = "full";
        format = "<small><i>%a</i></small>\\n<b><i>%s</i></b>\\n%b";
        alignment = "right";
        show_age_threshold = "1m";
        word_wrap = true;
        icon_position = "right";
        max_icon_size = 256;
        browser = lib.getExe config.programs.firefox.package;
      };
      urgency_low = {
        background = "#303446";
        foreground = "#c6d0f5";
        frame_color = "#303446";
        timeout = 5;
      };
      urgency_normal = {
        background = "#303446";
        foreground = "#c6d0f5";
        frame_color = "#ca9ee6";
        timeout = 5;
      };
      urgency_critical = {
        background = "#303446";
        foreground = "#c6d0f5";
        frame_color = "#e78284";
        timeout = 0;
      };
    };
  };
}
