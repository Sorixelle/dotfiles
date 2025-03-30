{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./modules/common.nix
    ./modules/desktop-theme.nix
    ./modules/discord.nix
    ./modules/dunst.nix
    ./modules/ghostty.nix
    ./modules/rofi.nix
    ./modules/sway.nix
    ./modules/xdg.nix
    ./modules/zen-browser.nix
  ];

  home.packages = with pkgs; [
    (aspellWithDicts (
      dicts: with dicts; [
        en
        en-computers
        en-science
      ]
    ))
    bitwarden
    cinny-desktop
    gimp
    nix-prefetch-scripts
    pavucontrol
    plexamp
    solaar
    wineWowPackages.staging
    winetricks
    xfce.thunar
    xfce.xfconf
    zulip
  ];

  manual.html.enable = true;

  catppuccin = {
    flavor = "frappe";
    accent = "lavender";
  };

  srxl.zen-browser.catppuccin.enable = true;

  srxl.sway = {
    battery = true;
    extraKeybinds = {
      # Lock screen
      "Mod4+Escape" = "exec ${lib.getExe config.programs.hyprlock.package}";

      # Volume control
      XF86AudioLowerVolume = "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_SINK@ 3%-";
      XF86AudioRaiseVolume = "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_SINK@ 3%+";
      XF86AudioMute = "exec ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_SINK@ toggle";

      # Media control
      XF86AudioPrev = "exec ${lib.getExe pkgs.playerctl} previous";
      XF86AudioNext = "exec ${lib.getExe pkgs.playerctl} next";
      XF86AudioPlay = "exec ${lib.getExe pkgs.playerctl} play-pause";

      # Brightness control
      XF86MonBrightnessUp = "exec ${lib.getExe pkgs.brightnessctl} s 5%+";
      XF86MonBrightnessDown = "exec ${lib.getExe pkgs.brightnessctl} s 5%-";
    };
  };
  wayland.windowManager.sway = {
    config = {
      input."type:touchpad".accel_profile = "flat";
      output.eDP-1.scale = "1.25";
    };
    extraConfig = ''
      # Lock screen when lid closed
      bindswitch lid:on exec ${lib.getExe config.programs.hyprlock.package}
    '';
  };

  programs = {
    chromium = {
      enable = true;
      package = pkgs.chromium;
      extensions = [
        { id = "nngceckbapebfimnlniiiahkandclblb"; } # Bitwarden
        { id = "cmpdlhmnmjhihmcfnigoememnffkimlk"; } # Catppuccin Theme
        { id = "ldpochfccmkkmhdbclfhpagapcfdljkj"; } # Decentraleyes
        { id = "pkehgijcmpdhfbdbbnkijodmdjhbjlgp"; } # Privacy Badger
        { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # uBlock Origin
      ];
    };
    hyprlock = {
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
  };

  services = {
    mpris-proxy.enable = true;

    swayidle = {
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
  };

  srxl = {
    emacs = {
      enable = true;
      server.enable = true;
      package = pkgs.emacs-unstable-pgtk;
    };

    email = {
      enable = true;
      watchFolders = [ "auxolotl" ];
      mu4eShortcuts = [
        {
          name = "Auxolotl";
          folder = "/auxolotl";
          key = "a";
        }
      ];
    };

    fonts = {
      monospace = {
        name = "Iosevka";
        size = 12;
        package = pkgs.iosevka-bin;
      };
      ui = {
        name = "Intur";
        size = 12;
        package = pkgs.inter-patched;
      };
      serif = {
        name = "ETBembo";
        size = 12;
        package = pkgs.etBook;
      };
      extraFonts = with pkgs; [
        emacs-all-the-icons-fonts
        nerd-fonts.symbols-only
        noto-fonts-cjk-sans
      ];
    };
  };

  systemd.user = {
    services = {
      polkit-gnome = {
        Unit = {
          Description = "GNOME Polkit authentication agent";
        };
        Service = {
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    };
  };

  home.stateVersion = "23.11";
}
