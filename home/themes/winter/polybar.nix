let colors = import ./colors.nix;
in config: pkgs: {
  enable = true;
  package = pkgs.polybar.override {
    mpdSupport = true;
    pulseSupport = true;
  };
  script = ''
    polybar desktop &
    polybar smallClock &
    polybar hour &
    polybar minute &
    polybar date &
  '';

  settings = let
    textFont = config.srxl.fonts.ui.name;
    iconFont = config.srxl.fonts.monospace.name;

    timeScript = pkgs.writeShellScript "polybar-time" ''
      if ${pkgs.bspwm}/bin/bspc query -N -d -n .window.!floating 2>&1 > /dev/null; then
        ${pkgs.coreutils}/bin/date "+%I:%M %P"
      else
        echo ""
      fi
    '';

    dateScript = pkgs.writeShellScript "polybar-date" ''
      function dateSuffix() {
        if [ "x`${pkgs.coreutils}/bin/date +%-d | ${pkgs.coreutils}/bin/cut -c2`x" = "xx" ]; then
          lastDigit=`${pkgs.coreutils}/bin/date +%-d`
        else
          lastDigit=`${pkgs.coreutils}/bin/date +%-d | ${pkgs.coreutils}/bin/cut -c2`
        fi

        day=`${pkgs.coreutils}/bin/date +%-d`
        case $lastDigit in
        0 )
          echo "th" ;;
        1 )
          if [ $day = "11" ]; then
            echo "th"
          else
            echo "st"
          fi ;;
        2 )
          if [ $day = "12" ]; then
            echo "th"
          else
            echo "nd"
          fi ;;
        3 )
          if [ $day = "13" ]; then
            echo "th"
          else
            echo "rd"
          fi ;;
        [4-9] )
          echo "th" ;;
        * )
          return 1 ;;
        esac
      }

      ${pkgs.coreutils}/bin/date "+%A, %-d`dateSuffix` of %B" | ${pkgs.gawk}/bin/awk '{print tolower($0)}'
    '';
  in {
    "bar/desktop" = {
      foreground = colors.bg;
      background = "#00000000";

      font = [
        "${textFont}:style=Light:size=12;2"
        "${iconFont}:size=12;2"
        "Noto Sans CJK JP:style=Light:size=12;2"
      ];

      height = 30;
      padding = {
        left = 2;
        right = 1;
      };

      modules = {
        left = "desktopIcon";
        right = "windowTitle";
      };

      tray = {
        position = "right";
        maxsize = 28;
      };

      override.redirect = false;
      wm.restack = "bspwm";
    };

    "bar/smallClock" = {
      foreground = colors.bg;
      background = "#00000000";

      font = [ "${textFont}:style=Light:size=12;2" ];

      height = 30;
      padding.left = 2;
      bottom = true;

      modules.left = "smallClock";

      override.redirect = false;
      wm.restack = "bspwm";
    };

    "bar/hour" = {
      foreground = colors.fg;
      background = "#00000000";

      font = [ "${textFont}:style=Light:size=96" ];

      height = 150;
      offset = {
        x = 64;
        y = 790;
      };

      modules.left = "hour";

      override.redirect = false;
      wm.restack = "bspwm";
    };

    "bar/minute" = {
      foreground = colors.fg;
      background = "#00000000";

      font = [
        "${textFont}:style=Light:size=96"
        "${textFont}:style=Light:size=64;8"
      ];

      height = 150;
      offset = {
        x = 64;
        y = 900;
      };

      modules.left = "minute";

      override.redirect = false;
      wm.restack = "bspwm";
    };

    "bar/date" = {
      foreground = colors.fg;
      background = "#00000000";

      font = [ "${textFont}:style=Light:size=48" ];

      height = 90;
      width = 1856;
      offset = { y = 942; };

      modules.right = "date";

      override.redirect = false;
      wm.restack = "bspwm";
    };

    "module/desktopIcon" = {
      type = "internal/bspwm";

      ws.icon = [
        "web;"
        "chat;"
        "code;"
        "terminals;"
        "games;"
        "files;"
        "gimp;"
      ];
      ws."icon-default" = "";

      format = "<label-state>";
      label = {
        focused.text = "%icon%  %name%";
        occupied.text = "";
        empty.text = "";
        urgent.foreground = colors.red;
      };
    };

    "module/windowTitle" = {
      type = "internal/xwindow";
      label.maxlen = 50;
    };

    "module/smallClock" = {
      type = "custom/script";
      exec = "${timeScript}";
      interval = 1;
    };

    "module/hour" = {
      type = "internal/date";
      time = "%I";
      label.text = "%time%";
    };

    "module/minute" = {
      type = "internal/date";
      date = "%M";
      time = "%P";
      label.text = "%date%%{T2}%time%";
    };

    "module/date" = {
      type = "custom/script";
      exec = "${dateScript}";
      interval = 1;
    };
  };
}
