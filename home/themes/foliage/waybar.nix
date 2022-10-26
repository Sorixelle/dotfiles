{ config, pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    package = pkgs.waybar.overrideAttrs
      (old: { mesonFlags = old.mesonFlags ++ [ "-Dexperimental=true" ]; });

    settings = {
      top = {
        layer = "top";
        output = [ "DP-4" "HDMI-A-2" ];
        position = "top";
        margin = "24";
        exclusive = false;

        modules-left = [ "custom/wintitle" ];

        "custom/wintitle" = {
          exec =
            "${config.wayland.windowManager.hyprland.package}/bin/hyprctl activewindow -j | ${pkgs.jq}/bin/jq -r .title | sed 's/&/&amp;/'";
          interval = 1;
          max-length = 50;
        };
      };

      bottom = {
        layer = "top";
        output = [ "DP-4" "HDMI-A-2" ];
        position = "bottom";
        margin = "24";
        exclusive = false;

        modules-left = [ "wlr/workspaces" ];
        modules-right = [ "tray" ];

        "wlr/workspaces" = {
          sort-by-name = false;
          sort-by-coordinates = false;
        };

        tray = {
          icon-size = 20;
          spacing = 8;
        };
      };
    };

    style = ''
      * {
        font-family: "Inter";
        font-size: 16px;
        font-feature-settings: "ss01, ss02";
      }

      window#waybar {
        background-color: rgba(0, 0, 0, 0);
      }

      #custom-wintitle, #tray {
        padding: 8px 12px;
        background-color: rgba(50, 41, 43, 0.8);
        border-radius: 24px;
      }

      #workspaces {
        padding: 4px;
        background-color: rgba(50, 41, 43, 0.8);
        border-radius: 24px;
      }
      #workspaces button {
        padding: 0 8px;
      }
      #workspaces button.active {
        color: #638a15;
      }
    '';
  };
}
