{ config, pkgs, ... }:

let
  inherit (import ../../npins) adw-catppuccin;
in
{
  # Get Catppuccin to style cursors, icons and Qt apps using Kvantum
  catppuccin = {
    cursors.enable = true;
    gtk.icon.enable = true;
    kvantum.enable = true;
  };

  # Allow customisation of cursor icons in GTK apps and in the Sway desktop
  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    sway.enable = true;
  };

  # Setup Catppuccin theming in GTK apps using adw-gtk3
  gtk =
    let
      inherit (config.catppuccin) flavor accent;
    in
    {
      enable = true;
      theme = {
        name = "adw-gtk3-dark";
        package = pkgs.adw-gtk3;
      };
      gtk3.extraCss = builtins.readFile "${adw-catppuccin}/themes/${flavor}/catppuccin-${flavor}-${accent}.css";
      gtk4.extraCss = builtins.readFile "${adw-catppuccin}/themes/${flavor}/catppuccin-${flavor}-${accent}.css";
    };

  # Setup Qt to use Kvantum styling
  qt = {
    enable = true;
    platformTheme.name = "kvantum";
    style.name = "kvantum";
  };
}
