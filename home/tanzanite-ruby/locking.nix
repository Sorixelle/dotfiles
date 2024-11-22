{
  config,
  lib,
  pkgs,
  ...
}:

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
          size = "750 125";
          position = "0 0";
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
          position = "32 32";
          valign = "bottom";
          halign = "left";
        }
        {
          text = "<i>$TIME</i>";
          color = "rgb(198, 208, 245)";
          font_size = 32;
          position = "-32 32";
          valign = "bottom";
          halign = "right";
        }
      ];
    };
  };

  services.swayidle = {
    enable = true;
    systemdTarget = "sway-session.target";

    events = [
      {
        event = "lock";
        command = "${pkgs.procps}/bin/pidof hyprlock || ${lib.getExe config.programs.hyprlock.package}";
      }
    ];

    timeouts = [
      {
        timeout = 300;
        command = "loginctl lock-session";
      }
      {
        timeout = 600;
        command = "systemctl suspend";
      }
    ];
  };

}
