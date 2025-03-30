{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ../modules/common.nix
    ../modules/desktop-theme.nix
    ../modules/dunst.nix
    ../modules/ghostty.nix
    ../modules/rofi.nix
    ../modules/sway.nix
    ../modules/xdg.nix
    ../modules/zen-browser.nix

    ./locking.nix
  ];

  home.packages = with pkgs; [
    (aspellWithDicts (
      dicts: with dicts; [
        en
        en-computers
        en-science
      ]
    ))
    betterdiscordctl
    bitwarden
    cinny-desktop
    discord
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
  };

  services = {
    mpris-proxy.enable = true;
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
