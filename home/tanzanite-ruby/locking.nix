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

      auth = {
        "pam:enabled" = false;
        "fingerprint:enabled" = true;
        "fingerprint:ready_message" = "unlock with fingerprint";
        "fingerprint:present_message" = "unlocking...";
      };

      background = [
        {
          path = "screenshot";
          blur_size = 3;
          blur_passes = 4;
          noise = 5.0e-2;
        }
      ];

      label = [
        {
          text = "$FPRINTPROMPT";
          font_size = 64;
          color = "rgb(198, 208, 245)";
          position = "0, 0";
          halign = "center";
          valign = "center";
        }
        {
          text = "<i>locked</i>";
          color = "rgb(198, 208, 245)";
          font_size = 40;
          position = "32px, 32px";
          valign = "bottom";
          halign = "left";
        }
        {
          text = "<i>$TIME</i>";
          color = "rgb(198, 208, 245)";
          font_size = 32;
          position = "-32px, 32px";
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
