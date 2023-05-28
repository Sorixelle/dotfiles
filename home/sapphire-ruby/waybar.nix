{ pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    package = pkgs.waybar-hyprland.overrideAttrs (old:
      let
        libcava = pkgs.cava.overrideAttrs (cavaOld: rec {
          pname = "libcava";
          version = "0.8.4";
          src = pkgs.fetchFromGitHub {
            owner = "LukashonakV";
            repo = "cava";
            rev = version;
            hash = "sha256-66uc0CEriV9XOjSjFTt+bxghEXY1OGrpjd+7d6piJUI=";
          };
          nativeBuildInputs = with pkgs; [ meson ninja pkg-config ];
          buildInputs = cavaOld.buildInputs ++ [ pkgs.pipewire pkgs.SDL2 ];
          mesonFlags =
            [ "-Dinput_portaudio=disabled" "-Dinput_sndio=disabled" ];
        });
      in {
        src = pkgs.fetchFromGitHub {
          owner = "Alexays";
          repo = "waybar";
          rev = "7b0d2e80434523eb22cf3bb5bdc41d590304a113";
          hash = "sha256-0QIKuFhOgclW3sxnmgbDAg7tGBg5YSKziLza/eqsaJ8=";
        };
        buildInputs = old.buildInputs ++ [ libcava pkgs.fftw ];
      });

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
        modules-center = [ "wlr/workspaces" ];
        modules-right = [ "cava" "mpris" "custom/mediaedge" "clock" ];

        "cava" = {
          framerate = 170;
          bars = 12;
          method = "pipewire";
          stereo = false;
          monstercat = true;
          bar_delimiter = 0;
          format-icons = [ "▁" "▂" "▃" "▄" "▅" "▆" "▇" "█" ];
        };

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

        "wlr/workspaces" = { on-click = "activate"; };
      };
    };

    style = ''
      * {
        font-family: Inter;
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
