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

  accent = "\$${config.catppuccin.accent}";
  palette =
    (builtins.fromJSON (builtins.readFile "${config.catppuccin.sources.palette}/palette.json"))
    .${config.catppuccin.flavor}.colors;

  cfg = config.srxl.sway;
in
{
  options.srxl.sway =
    let
      inherit (lib) mkEnableOption mkOption types;
    in
    {
      battery = mkEnableOption "battery indicator in the bar";

      extraKeybinds = mkOption {
        type = types.attrsOf (types.nullOr types.str);
        default = { };
        description = ''
          Extra keybindings to add to sway.
        '';
      };

      extraBarConfig = mkOption {
        type = types.lines;
        default = "";
        description = ''
          Extra config to add to the swaybar.
        '';
      };
    };

  config = {
    catppuccin.sway.enable = true;

    wayland.windowManager.sway = {
      enable = true;
      config = {
        colors = {
          focused = {
            background = accent;
            border = accent;
            childBorder = accent;
            indicator = "$pink";
            text = "$base";
          };
          focusedInactive = {
            background = "$surface0";
            border = "$surface0";
            childBorder = "$surface0";
            indicator = "$surface0";
            text = "$text";
          };
          unfocused = {
            background = "$base";
            border = "$base";
            childBorder = "$base";
            indicator = "$base";
            text = "$text";
          };
          urgent = {
            background = "$red";
            border = "$red";
            childBorder = "$red";
            indicator = "$red";
            text = "$base";
          };
        };

        fonts = {
          names = [ "Intur" ];
          size = 12.0;
        };
        window.border = 4;
        seat.seat0.hide_cursor = "5000";

        modifier = "Mod4";
        workspaceAutoBackAndForth = true;
        defaultWorkspace = "workspace 1:web";
        keybindings =
          let
            mod = config.wayland.windowManager.sway.config.modifier;
          in
          lib.mkOptionDefault (
            {
              "${mod}+Return" = "exec ${lib.getExe config.programs.ghostty.package}";
              "${mod}+space" = "exec ${lib.getExe config.programs.rofi.package} -show drun";

              "${mod}+q" = "kill";
              "${mod}+Shift+q" = "exit"; # TODO: swaynag

              # Screenshots
              "${mod}+s" = "exec ${lib.getExe pkgs.scr} -Mode Active -Clipboard";
              "${mod}+Shift+s" = "exec ${lib.getExe pkgs.scr} -Mode Selection -Clipboard";
              "${mod}+Mod1+s" = "exec ${lib.getExe pkgs.scr} -Mode Screen -Clipboard";

              # Workspaces
              "${mod}+1" = "workspace 1:web";
              "${mod}+2" = "workspace 2:chat";
              "${mod}+3" = "workspace 3:dev";
              "${mod}+Shift+1" = "move container to workspace 1:web";
              "${mod}+Shift+2" = "move container to workspace 2:chat";
              "${mod}+Shift+3" = "move container to workspace 3:dev";

              # Try to open scratchpad terminal - if none exists, open a new one
              "${mod}+grave" =
                "exec (swaymsg \"[app_id=scratchpad.term] scratchpad show\") || ${lib.getExe config.programs.ghostty.package} --class=scratchpad.term";
            }
            // cfg.extraKeybinds
          );

        startup = [
          # Set wallpaper on boot and after reload
          {
            command = "${changeWpScript}";
            always = true;
          }

          # Other startup apps
          { command = "${lib.getExe config.programs.zen-browser.package}"; }
          { command = "${pkgs.gtk3}/bin/gtk-launch senpai.desktop"; }
          { command = "discord"; }
          { command = "cinny"; }
        ];

        assigns = {
          "1:web" = [ { app_id = "zen"; } ];
          "2:chat" = [
            { app_id = "app.senpai"; }
            { app_id = "cinny"; }
            { app_id = "discord"; }
            { app_id = "signal"; }
            { app_id = "Zulip"; }
          ];
          "3:dev" = [ { app_id = "emacs"; } ];
        };

        bars = [
          {
            colors = {
              background = "$base";
              statusline = "$text";
              bindingMode = {
                background = "$surface1";
                border = "$surface1";
                text = "$text";
              };
              focusedWorkspace = {
                background = accent;
                border = accent;
                text = "$surface1";
              };
              activeWorkspace = {
                background = "$surface1";
                border = "$surface1";
                text = "$text";
              };
              inactiveWorkspace = {
                background = "$surface0";
                border = "$surface0";
                text = "$text";
              };
              urgentWorkspace = {
                background = "$red";
                border = "$red";
                text = "$surface1";
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

            extraConfig = cfg.extraBarConfig;
          }
        ];
      };

      swaynag = {
        enable = true;
        settings = {
          yubikey = {
            font = "Intur 12";
            background = palette.base.hex;
            border = palette.base.hex;
            button-background = palette.surface0.hex;
            text = palette.text.hex;
            border-bottom-size = 0;
            message-padding = 8;
          };
        };
      };

      extraConfig = ''
        for_window {
          # Scratchpad
          [app_id=scratchpad.term] floating enable; resize set 1600 850; move position center; move to scratchpad; scratchpad show
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
            theme = "ctp-${config.catppuccin.flavor}";
            overrides = {
              separator = "";
              info_bg = palette.${config.catppuccin.accent}.hex;
            };
          };

          blocks =
            [
              {
                block = "focused_window";
                format = " $title |";
              }
              {
                block = "cpu";
                format = " cpu: $utilization.eng(w:1) |";
                theme_overrides.idle_bg = palette.surface1.hex;
              }
              {
                block = "memory";
                format = " mem: $mem_used_percents.eng(w:1) |";
                format_alt = " mem: $mem_used / $mem_total |";
                theme_overrides.idle_bg = palette.surface1.hex;
              }
            ]
            ++ (lib.optional cfg.battery {
              block = "battery";
              device = "BAT1";
              format = " bat: $percentage.eng(w:1) |";
              full_format = " bat: 100% |";
              charging_format = " bat: $percentage.eng(w:1) \(charging\) |";
              theme_overrides.idle_bg = palette.green.hex;
              theme_overrides.idle_fg = palette.base.hex;
            })
            ++ [
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
  };
}
