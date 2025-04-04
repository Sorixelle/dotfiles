{ config, ... }:

let
  palette =
    (builtins.fromJSON (builtins.readFile "${config.catppuccin.sources.palette}/palette.json"))
    .${config.catppuccin.flavor}.colors;
in
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
        separator_height = 4;
        font = "${config.srxl.fonts.ui.name} ${toString config.srxl.fonts.ui.size}";
        markup = "full";
        format = "<small><i>%a</i></small>\\n<b><i>%s</i></b>\\n%b";
        alignment = "right";
        show_age_threshold = "1m";
        word_wrap = true;
        icon_position = "right";
        max_icon_size = 256;
      };
      urgency_low.timeout = 5;
      urgency_normal.timeout = 5;
      urgency_critical.timeout = 0;
    };
  };

  # Override parts of Catppuccin's theming that I don't like
  xdg.configFile."dunst/dunstrc.d/10-theme-override.conf".text = ''
    [global]
    frame_color = "${palette.${config.catppuccin.accent}.hex}"
    highlight = "${palette.${config.catppuccin.accent}.hex}"

    [urgency_low]
    frame_color = "${palette.surface1.hex}"

    [urgency_critical]
    frame_color = "${palette.red.hex}"
  '';

  catppuccin.dunst.enable = true;
}
