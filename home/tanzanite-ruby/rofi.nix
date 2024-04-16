{ config, pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;

    location = "center";
    terminal = "${config.programs.kitty.package}/bin/kitty";

    extraConfig = { display-drun = "Launch:"; };

    theme = let
      lit = config.lib.formats.rasi.mkLiteral;

      bg = "#303446";
      bg-light = "#414559";
      fg = "#c6d0f5";
      highlight = "#ca9ee6";
    in {
      window = {
        padding = lit "16px";
        border-radius = lit "32px";
        background-color = lit bg;
      };

      mainbox = { background-color = lit bg; };

      inputbar = {
        children = map lit [ "prompt" "entry" ];
        border-radius = lit "32px";
        padding = lit "16px";
        background-color = lit bg-light;
        spacing = lit "12px";
      };

      prompt = {
        background-color = lit bg-light;
        font = "Intur 24";
        text-color = lit fg;
      };

      entry = {
        background-color = lit bg-light;
        font = "Intur Bold Italic 24";
        text-color = lit fg;
      };

      listview = {
        lines = 6;
        margin = lit "16px 0 0 0";
        background-color = lit bg;
      };

      element = {
        children = map lit [ "element-icon" "element-text" ];
        padding = lit "4px";
        border-radius = lit "8px";
        spacing = lit "16px";
      };

      "element, element-icon, element-text" = {
        background-color = lit bg;
        text-color = lit fg;
      };

      "element selected, element-text selected, element-icon selected" = {
        background-color = lit bg-light;
      };

      element-icon = { size = lit "64px"; };

      element-text = {
        font = "Intur 18";
        vertical-align = lit "0.5";
        highlight = lit "bold italic ${highlight}";
      };
    };
  };
}
