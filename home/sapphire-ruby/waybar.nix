{ ... }:

{
  programs.waybar = {
    enable = true;

    systemd = {
      enable = true;
      target = "hyprland-session.target";
    };

    settings = {
      topbar = {
        layer = "top";
        margin = "16 16 0 16";
        name = "topbar";
        modules-left = [ "hyprland/window" ];
        modules-center = [ "hyprland/workspaces" ];
        modules-right = [ "mpris" "custom/mediaedge" "clock" ];

        # TODO: why did this break?
        # "cava" = {
        #   framerate = 170;
        #   bars = 12;
        #   method = "pipewire";
        #   stereo = false;
        #   monstercat = true;
        #   bar_delimiter = 0;
        #   format-icons = [ "▁" "▂" "▃" "▄" "▅" "▆" "▇" "█" ];
        # };

        "clock" = {
          interval = 1;
          format = "{:%I:%M %p}";
        };

        "custom/mediaedge" = { format = " "; };

        "hyprland/window" = {
          separate-outputs = true;
          max-length = 50;
        };

        "mpris" = {
          format = "{status_icon} <i>{artist} - {title}</i>";
          interval = 1;
          status-icons = {
            playing = "󰐊";
            paused = "󰏤";
            stopped = "󰓛";
          };
        };

        "hyprland/workspaces" = { };
      };
    };

    style = ''
      * {
        font-family: Intur;
        font-size: 16px;
      }

      window#waybar {
        background-color: rgba(0, 0, 0, 0);
        color: #cad3f5;
      }

      .modules-left {
        padding: 8px;
        border-radius: 8px;
        background-color: #24273a;
        font-style: italic;
        border-left: 4px solid #7dc4e4;
      }

      .modules-center {
        margin: 0 16px;
        padding: 8px;
        border-radius: 8px;
        background-color: #24273a;
      }

      #clock {
        padding: 8px;
        border-radius: 8px;
        background-color: #24273a;
        border-right: 4px solid #ee99a0;
      }

      #custom-mediaedge {
        padding-left: 8px;
        margin-right: 16px;
        border-top-right-radius: 8px;
        border-bottom-right-radius: 8px;
        background-color: #24273a;
        border-right: 4px solid #a6da95;
      }

      #mpris {
        padding-left: 8px;
        background-color: #24273a;

        /* TODO: remove when cava fixed */
        border-top-left-radius: 8px;
        border-bottom-left-radius: 8px;
      }

      #cava {
        padding: 8px;
        border-top-left-radius: 8px;
        border-bottom-left-radius: 8px;
        background-color: #24273a;
      }

      #workspaces button {
        padding: 4px 8px;
        border-radius: 16px;
      }

      #workspaces button.active {
        background-color: #c6a0f6;
        color: #24273a;
      }
    '';
  };

  services.playerctld.enable = true;
}
