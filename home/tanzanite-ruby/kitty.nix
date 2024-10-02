{ ... }:

{
  programs.kitty = {
    enable = true;

    themeFile = "Catppuccin-Frappe";
    font = {
      name = "Iosevka Term";
      size = 12;
    };

    settings = {
      background_opacity = "0.6";
      scrollback_pager_history_size = 32;
      repaint_delay = 5;
      window_padding_width = 16;
      tab_bar_margin_height = "8 0";
    };
  };
}
