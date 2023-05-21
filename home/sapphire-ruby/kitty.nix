{ ... }:

{
  programs.kitty = {
    enable = true;

    theme = "Catppuccin-Macchiato";
    font = {
      name = "IBM Plex Mono";
      size = 12;
    };

    settings = {
      scrollback_pager_history_size = 32;
      repaint_delay = 5;
      window_padding_width = 16;
      tab_bar_margin_height = "8 0";
    };

    extraConfig = ''
      font_features IBMPlexMono +ss02 +ss03
      font_features IBMPlexMono-Italic +ss02 +ss03
      font_features IBMPlexMono-Bold +ss02 +ss03
      font_features IBMPlexMono-BoldItalic +ss02 +ss03
    '';
  };
}
