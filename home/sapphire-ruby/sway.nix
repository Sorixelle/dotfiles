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
          background = "#8bd5ca";
          border = "#8bd5ca";
          childBorder = "#8bd5ca";
          indicator = "#f5bde6";
          text = "#24273a";
        };
        focusedInactive = {
          background = "#363a4f";
          border = "#363a4f";
          childBorder = "#363a4f";
          indicator = "#363a4f";
          text = "#cad3f5";
        };
        unfocused = {
          background = "#24273a";
          border = "#24273a";
          childBorder = "#24273a";
          indicator = "#24273a";
          text = "#cad3f5";
        };
        urgent = {
          background = "#ed8796";
          border = "#ed8796";
          childBorder = "#ed8796";
          indicator = "#ed8796";
          text = "#24273a";
        };
      };
      fonts = {
        names = [ "Intur" ];
        size = 12.0;
      };
      window.border = 4;
      seat.seat0 = {
        xcursor_theme = "${config.gtk.cursorTheme.name} 24";
        hide_cursor = "5000";
      };

      # Hardware
      output = {
        DP-1 = {
          mode = "2560x1440@164.958Hz";
          render_bit_depth = "10";
        };
      };

      # Keybindings
      modifier = "Mod4";
      keybindings =
        let
          mod = config.wayland.windowManager.sway.config.modifier;
        in
        lib.mkOptionDefault {
          "${mod}+Return" = "exec ${config.programs.kitty.package}/bin/kitty";
          "${mod}+space" = "exec ${config.programs.rofi.package}/bin/rofi -show drun";

          "${mod}+q" = "kill";
          "${mod}+Shift+q" = "exit"; # TODO: swaynag

          # Screenshots
          "${mod}+s" = "exec ${pkgs.scr}/bin/scr -Mode Active -Clipboard";
          "${mod}+Shift+s" = "exec ${pkgs.scr}/bin/scr -Mode Selection -Clipboard";
          "${mod}+Mod1+s" = "exec ${pkgs.scr}/bin/scr -Mode Screen -Clipboard";

          # Workspaces
          "${mod}+1" = "workspace 1:web";
          "${mod}+2" = "workspace 2:chat";
          "${mod}+3" = "workspace 3:dev";
          "${mod}+Shift+1" = "move container to workspace 1:web";
          "${mod}+Shift+2" = "move container to workspace 2:chat";
          "${mod}+Shift+3" = "move container to workspace 3:dev";

          # Monitors
          "${mod}+bracketleft" = "move workspace output left";
          "${mod}+bracketright" = "move workspace output right";

          # Try to open scratchpad terminal - if none exists, open a new one
          "${mod}+grave" =
            "exec (swaymsg \"[app_id=scratchpad_term] scratchpad show\") || ${lib.getExe config.programs.kitty.package} --app-id scratchpad_term";
        };

      workspaceAutoBackAndForth = true;
      defaultWorkspace = "workspace 1:web";
      workspaceOutputAssign = [
        {
          workspace = "1:web";
          output = "DP-1";
        }
        {
          workspace = "2:chat";
          output = "HDMI-A-1";
        }
        {
          workspace = "3:dev";
          output = "DP-1";
        }
      ];

      startup = [
        # Set wallpaper on boot and after reload
        {
          command = "${changeWpScript}";
          always = true;
        }

        # Other startup apps
        { command = "${lib.getExe config.programs.zen-browser.package}"; }
        { command = "discord"; }
        { command = "cinny"; }
        { command = "zulip"; }
      ];

      assigns = {
        "1:web" = [ { app_id = "zen"; } ];
        "2:chat" = [
          { app_id = "discord"; }
          { app_id = "cinny"; }
          { app_id = "Zulip"; }
        ];
        "3:dev" = [ { app_id = "emacs"; } ];
      };

      bars = [
        {
          colors = {
            background = "#24273a";
            statusline = "#cad3f5";
            bindingMode = {
              background = "#494d64";
              border = "#494d64";
              text = "#cad3f5";
            };
            focusedWorkspace = {
              background = "#8bd5ca";
              border = "#8bd5ca";
              text = "#494d64";
            };
            activeWorkspace = {
              background = "#494d64";
              border = "#494d64";
              text = "#cad3f5";
            };
            inactiveWorkspace = {
              background = "#363a4f";
              border = "#363a4f";
              text = "#cad3f5";
            };
            urgentWorkspace = {
              background = "#ed8796";
              border = "#ed8796";
              text = "#494d64";
            };
          };
          fonts = {
            names = [
              "Intur"
              "Symbols Nerd Font"
            ];
            size = 12.0;
          };

          trayOutput = "*";
          trayPadding = 4;

          statusCommand = "${lib.getExe config.programs.i3status-rust.package} config-default.toml";

          extraConfig = ''
            output HDMI-A-1
            output DP-1
          '';
        }
      ];
    };

    swaynag = {
      enable = true;
      settings = {
        yubikey = {
          font = "Intur 12";
          background = "24273a";
          border = "24273a";
          button-background = "363a4f";
          text = "cad3f5";
          border-bottom-size = 0;
          message-padding = 8;
        };
      };
    };

    extraConfig = ''
      for_window {
        # Scratchpad
        [app_id=scratchpad_term] floating enable; resize set 1600 850; move position center; move to scratchpad; scratchpad show
        [app_id=discord] layout tabbed
      }
    '';
  };

  services.wlsunset.systemdTarget = "sway-session.target";

  programs.i3status-rust = {
    enable = true;
    bars = {
      default = {
        icons = "awesome6";
        settings.theme = {
          theme = "ctp-macchiato";
          overrides = {
            separator = "";
            info_bg = "#8bd5ca";
          };
        };

        blocks = [
          {
            block = "focused_window";
            format = " $title |";
          }
          {
            block = "cpu";
            format = " cpu: $utilization.eng(w:1) |";
            theme_overrides.idle_bg = "#494d64";
          }
          {
            block = "memory";
            format = " mem: $mem_used_percents.eng(w:1) |";
            format_alt = " mem: $mem_used / $mem_total |";
            theme_overrides.idle_bg = "#494d64";
          }
          {
            block = "music";
            format = " Now Playing: $artist - $title $prev $play $next |";
            click = [
              {
                button = "left";
                action = "play_pause";
              }
            ];
          }
          {
            block = "time";
            interval = 1;
            format = " $timestamp.datetime(f:'%a %d/%m %I:%M %P') ";
          }
        ];
      };
    };
  };

  systemd.user = {
    services = {
      change-wp = {
        Unit.Description = "Change the wallpaper to a random one";
        Service = {
          Type = "oneshot";
          ExecStart = "${changeWpScript}";
        };
      };

      yubikey-alert = {
        Unit.Description = "Display alert when Yubikey touch requested";
        Service.ExecStart = lib.getExe (
          pkgs.yubikey-touch-alert.override {
            sway = config.wayland.windowManager.sway.package;
          }
        );
        Install.WantedBy = [ "sway-session.target" ];
      };
    };
    timers.change-wp = {
      Unit.Description = "Change wallpaper every hour";
      Timer = {
        OnStartupSec = "1h";
        OnUnitActiveSec = "1h";
      };
      Install.WantedBy = [ "sway-session.target" ];
    };
  };
}
