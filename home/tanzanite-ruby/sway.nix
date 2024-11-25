{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Script to select a random wallpaper and load it
  changeWpScript = pkgs.writeScript "change-wp" ''
    #!${pkgs.fish}/bin/fish

    ${config.wayland.windowManager.sway.package}/bin/swaymsg output '*' bg (random choice ~/img/papes/*) fill
  '';
in
{
  wayland.windowManager.sway = {
    enable = true;

    # Styling
    config = {
      colors = {
        focused = {
          background = "#ca9ee6";
          border = "#ca9ee6";
          childBorder = "#ca9ee6";
          indicator = "#85c1dc";
          text = "#303446";
        };
        focusedInactive = {
          background = "#414559";
          border = "#414559";
          childBorder = "#414559";
          indicator = "#414559";
          text = "#c6d0f5";
        };
        unfocused = {
          background = "#303446";
          border = "#303446";
          childBorder = "#303446";
          indicator = "#303446";
          text = "#c6d0f5";
        };
        urgent = {
          background = "#e78284";
          border = "#e78284";
          childBorder = "#e78284";
          indicator = "#e78284";
          text = "#303446";
        };
      };
      fonts = {
        names = [ "Intur" ];
        size = 12.0;
      };
      window.border = 4;
      seat.seat0.xcursor_theme = "${config.gtk.cursorTheme.name} 24";

      # Hardware
      input = {
        "type:touchpad".accel_profile = "flat";
      };
      output = {
        eDP-1.scale = "1.25";
      };

      # Keybindings
      modifier = "Mod4";
      workspaceAutoBackAndForth = true;
      defaultWorkspace = "workspace 1:web";
      keybindings =
        let
          mod = config.wayland.windowManager.sway.config.modifier;
        in
        lib.mkOptionDefault {
          "${mod}+Return" = "exec ${config.programs.kitty.package}/bin/kitty";
          "${mod}+space" = "exec ${config.programs.rofi.package}/bin/rofi -show drun";

          "${mod}+q" = "kill";
          "${mod}+Shift+q" = "exit"; # TODO: swaynag
          "${mod}+Escape" = "exec ${lib.getExe config.programs.hyprlock.package}";

          # Screenshots
          "${mod}+s" = "exec ${pkgs.scr}/bin/scr -Mode Active -Clipboard";
          "${mod}+Shift+s" = "exec ${pkgs.scr}/bin/scr -Mode Selection -Clipboard";
          "${mod}+Mod1+s" = "exec ${pkgs.scr}/bin/scr -Mode Screen -Clipboard";

          "${mod}+1" = "workspace 1:web";
          "${mod}+2" = "workspace 2:chat";
          "${mod}+3" = "workspace 3:dev";

          # Try to open scratchpad terminal - if none exists, open a new one
          "${mod}+grave" = "exec (swaymsg \"[app_id=scratchpad_term] scratchpad show\") || ${lib.getExe config.programs.kitty.package} --app-id scratchpad_term";

          # Volume control
          XF86AudioLowerVolume = "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_SINK@ 3%-";
          XF86AudioRaiseVolume = "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_SINK@ 3%+";
          XF86AudioMute = "exec ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_SINK@ toggle";

          # Media control
          XF86AudioPrev = "exec ${pkgs.playerctl}/bin/playerctl previous";
          XF86AudioNext = "exec ${pkgs.playerctl}/bin/playerctl next";
          XF86AudioPlay = "exec ${pkgs.playerctl}/bin/playerctl play-pause";

          # Brightness control
          XF86MonBrightnessUp = "exec ${pkgs.brightnessctl}/bin/brightnessctl s 5%+";
          XF86MonBrightnessDown = "exec ${pkgs.brightnessctl}/bin/brightnessctl s 5%-";
        };

      startup = [
        # Set wallpaper on boot and after reload
        {
          command = "${changeWpScript}";
          always = true;
        }

        # Other startup apps
        { command = "${lib.getExe config.programs.firefox.package}"; }
        { command = "discord"; }
        { command = "nheko"; }
        { command = "zulip"; }
      ];

      assigns = {
        "1:web" = [ { app_id = "firefox"; } ];
        "2:chat" = [
          { app_id = "discord"; }
          { app_id = "nheko"; }
          { app_id = "Zulip"; }
        ];
        "3:dev" = [ { app_id = "emacs"; } ];
      };

      bars = [
        {
          colors = {
            background = "#303446";
            statusline = "#c6d0f5";
            bindingMode = {
              background = "#51576d";
              border = "#51576d";
              text = "#c6d0f5";
            };
            focusedWorkspace = {
              background = "#ca9ee6";
              border = "#ca9ee6";
              text = "#303446";
            };
            inactiveWorkspace = {
              background = "#414559";
              border = "#414559";
              text = "#c6d0f5";
            };
            urgentWorkspace = {
              background = "#e78284";
              border = "#e78284";
              text = "#303446";
            };
          };
          fonts = {
            names = [ "Intur" ];
            size = 12.0;
          };

          trayOutput = "*";
          trayPadding = 4;

          # TODO: better status command
          statusCommand = lib.getExe pkgs.i3status;
        }
      ];
    };

    extraConfig = ''
      # Lock screen when lid closed
      bindswitch lid:on exec ${config.programs.hyprlock.package}/bin/hyprlock

      for_window {
        # Scratchpad
        [app_id=scratchpad_term] floating enable; resize set 1600 850; move position center; move to scratchpad; scratchpad show

        [app_id=discord] layout tabbed
      }
    '';
  };

  # Wallpaper rotation units
  systemd.user = {
    services.change-wp = {
      Unit.Description = "Change the wallpaper to a random one";
      Service = {
        Type = "oneshot";
        ExecStart = "${changeWpScript}";
      };
    };
    timers.change-wp = {
      Unit.Description = "Change wallpaper every hour";
      Timer.OnStartupSec = "1h";
      Install.WantedBy = [ "sway-session.target" ];
    };
  };
}
