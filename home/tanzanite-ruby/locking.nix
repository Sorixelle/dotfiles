{ config, pkgs, ... }:

{
  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        hide_cursor = true;
      };

      background = [
        {
          path = "screenshot";
          blur_size = 3;
          blur_passes = 4;
          noise = 5.0e-2;
        }
      ];

      input-field = [
        {
          size = {
            width = 750;
            height = 125;
          };
          position = {
            x = 0;
            y = 0;
          };
          halign = "center";
          valign = "center";

          font_color = "rgb(48, 52, 70)";
          inner_color = "rgba(115, 121, 148, 0.8)";
          outer_color = "rgb(115, 121, 148)";
          check_color = "rgb(229, 200, 144)";
          fail_color = "rgb(231, 130, 132)";

          placeholder_text = "";
          fail_text = "";
          fade_on_empty = false;
        }
      ];

      label = [
        {
          text = "<i>locked</i>";
          color = "rgb(198, 208, 245)";
          font_size = 40;
          position = {
            x = 32;
            y = 32;
          };
          valign = "bottom";
          halign = "left";
        }
        {
          text = "<i>$TIME</i>";
          color = "rgb(198, 208, 245)";
          font_size = 32;
          position = {
            x = -32;
            y = 32;
          };
          valign = "bottom";
          halign = "right";
        }
      ];
    };
  };

  services.hypridle =
    let
      hyprland = config.wayland.windowManager.hyprland.package;
      hyprlock = config.programs.hyprlock.package;
    in
    {
      enable = true;

      settings = {
        lockCmd = "${pkgs.procps}/bin/pidof hyprlock || ${hyprlock}/bin/hyprlock";
        afterSleepCmd = "${hyprland}/bin/hyprctl dispatch dpms on";

        listener = [
          {
            timeout = 300;
            onTimeout = "loginctl lock-session";
          }
          {
            timeout = 330;
            onTimeout = "${hyprland}/bin/hyprctl dispatch dpms off";
            onResume = "${hyprland}/bin/hyprctl dispatch dpms on";
          }
          {
            timeout = 600;
            onTimeout = "systemctl suspend";
          }
        ];
      };
    };

}
