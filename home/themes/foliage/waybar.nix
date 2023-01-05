{ config, pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    package = pkgs.waybar.overrideAttrs
      (old: { mesonFlags = old.mesonFlags ++ [ "-Dexperimental=true" ]; });

    settings = {
      top = {
        layer = "top";
        output = [ "DP-3" "HDMI-A-1" ];
        position = "top";
        margin = "24";
        exclusive = false;

        modules-left = [ "custom/wintitle" "mpd" ];

        "custom/wintitle" = {
          exec =
            "${config.wayland.windowManager.hyprland.package}/bin/hyprctl activewindow -j | ${pkgs.jq}/bin/jq -r .title";
          interval = 1;
          max-length = 50;
        };

        mpd = {
          format = "{stateIcon} {artist} - {title}";
          format-paused = "{stateIcon} {artist} - {title}";
          format-stopped = " Stopped";
          state-icons = {
            playing = "";
            paused = "";
          };

          on-click = "${pkgs.mpc-cli}/bin/mpc toggle";
          on-click-right = "${pkgs.mpc-cli}/bin/mpc next";
          on-click-middle = "${pkgs.mpc-cli}/bin/mpc prev";
        };
      };

      bottom = {
        layer = "top";
        output = [ "DP-3" "HDMI-A-1" ];
        position = "bottom";
        margin = "24";
        exclusive = false;

        modules-left = [ "wlr/workspaces" ];

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

      #custom-wintitle, #tray, #mpd {
        padding: 8px 12px;
        background-color: rgba(50, 41, 43, 0.8);
        border-radius: 24px;
      }

      #mpd {
        margin-left: 12px;
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
