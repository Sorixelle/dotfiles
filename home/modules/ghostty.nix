{
  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;

    settings = {
      font-family = [
        "Iosevka Term"
        "Symbols Nerd Font Mono"
      ];
      font-size = 12;

      mouse-hide-while-typing = true;

      background-opacity = 0.9;
      window-padding-x = 16;
      window-padding-y = 16;
      window-padding-balance = true;

      scrollback-limit = 50000000; # 50MB scrollback buffer
      gtk-single-instance = true;
    };
  };

  catppuccin.ghostty.enable = true;
}
