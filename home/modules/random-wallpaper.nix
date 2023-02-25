{ config, lib, pkgs, ... }:

{
  options.srxl.randomWallpaper = with lib; {
    enable = mkEnableOption
      "a service for periodically switching to random wallpapers.";

    directory = mkOption {
      type = types.str;
      default = "~/usr/img/papes";
      description = ''
        The path where wallapers are stored.
      '';
    };

    duration = mkOption {
      type = types.str;
      default = "*:00:00";
      description = ''
        How often to switch wallpapers.

        Follows the same format at systemd's OnCalendar - check systemd.time(7) for details.
      '';
    };
  };

  config = let
    conf = config.srxl.randomWallpaper;

    switcherScript = pkgs.writeShellScript "wallpaper-switch" ''
      ${pkgs.feh}/bin/feh --randomize --bg-fill ${conf.directory}/*
    '';
  in lib.mkIf conf.enable {
    systemd.user = {
      services.switch-wallpaper = {
        Unit = { Description = "Switch wallpaper to a random image"; };
        Service = {
          Type = "oneshot";
          ExecStart = "${switcherScript}";
        };
      };

      timers.switch-wallpaper = {
        Unit = { Description = "Periodically switch wallpapers"; };
        Timer = {
          OnCalendar = conf.duration;
          OnStartupSec = "0";
        };
        Install = { WantedBy = [ "graphical-session.target" ]; };
      };
    };
  };
}
