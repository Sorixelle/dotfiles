_:

{
  programs.kitty = {
    enable = true;

    themeFile = "Catppuccin-Macchiato";
    font = {
      name = "Iosevka Term";
      size = 12;
    };

    settings = {
      background_opacity = "0.9";
      scrollback_pager_history_size = 32;
      repaint_delay = 5;
      window_padding_width = 16;
      tab_bar_margin_height = "8 0";
    };
  };
}
