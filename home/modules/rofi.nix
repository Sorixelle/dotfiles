{ config, pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;

    location = "center";
    terminal = "${config.programs.kitty.package}/bin/kitty";

    extraConfig = {
      display-drun = "Launch:";
    };

    theme =
      let
        lit = config.lib.formats.rasi.mkLiteral;
      in
      {
        window = {
          padding = lit "16px";
          border-radius = lit "32px";
        };

        inputbar = {
          children = map lit [
            "prompt"
            "entry"
          ];
          border-radius = lit "32px";
          padding = lit "16px";
          spacing = lit "12px";
        };

        prompt.font = "Intur 24";

        entry.font = "Intur Bold Italic 24";

        listview = {
          lines = 6;
          margin = lit "16px 0 0 0";
        };

        element = {
          children = map lit [
            "element-icon"
            "element-text"
          ];
          padding = lit "4px";
          border-radius = lit "8px";
          spacing = lit "16px";
        };

        element-icon = {
          size = lit "64px";
        };

        element-text = {
          font = "Intur 18";
          vertical-align = lit "0.5";
        };
      };
  };

  catppuccin.rofi.enable = true;
}
