{
  # Get Catppuccin to style cursors, GTK and Qt apps
  catppuccin = {
    cursors.enable = true;
    gtk = {
      enable = true;
      icon.enable = true;
      tweaks = [ "rimless" ];
    };
    kvantum.enable = true;
  };

  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    sway.enable = true;
  };

  gtk.enable = true;

  qt = {
    enable = true;
    platformTheme.name = "kvantum";
    style.name = "kvantum";
  };
}
