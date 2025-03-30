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
    ./modules/dunst.nix
    ./modules/ghostty.nix
    ./modules/xdg.nix
    ./modules/rofi.nix
    ./modules/sway.nix
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
    betterdiscordctl
    bitwarden
    calibre
    cinny-desktop
    darktable
    discord
    ffmpeg-full
    figma-linux
    gimp
    nix-prefetch-scripts
    osu-lazer-bin
    parsec-bin
    pavucontrol
    picard
    plexamp
    prismlauncher
    qbittorrent
    roon-launcher
    scr
    signal-desktop
    solaar
    steam
    virt-manager
    winbox
    wineWowPackages.staging
    winetricks
    xfce.thunar
    xfce.xfconf
    xsane
    zulip
  ];

  catppuccin = {
    flavor = "macchiato";
    accent = "teal";
  };

  srxl.zen-browser.catppuccin.enable = true;

  srxl.sway = {
    extraKeybinds =
      let
        mod = config.wayland.windowManager.sway.config.modifier;
      in
      {
        "${mod}+bracketleft" = "move workspace output left";
        "${mod}+bracketright" = "move workspace output right";
      };
    extraBarConfig = ''
      output HDMI-A-1
      output DP-1
    '';
  };
  wayland.windowManager.sway.config = {
    output = {
      DP-1 = {
        mode = "2560x1440@164.958Hz";
        render_bit_depth = "10";
      };
    };
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
  };

  # Override default in modules/xdg.nix - point at music library on fluorite's media share
  xdg.userDirs.music = lib.mkForce "$HOME/media/Library/Music";

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

    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        obs-pipewire-audio-capture
        wlrobs
      ];
    };
  };

  services = {
    easyeffects = {
      enable = true;
      preset = "DT880";
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
      mu4eShortcuts = [
        {
          name = "Emacs Announcements";
          folder = "/ruby-srxl/info-gnu-emacs";
          key = "e";
        }
        {
          name = "mu4e Mailing List";
          folder = "/ruby-srxl/mu-discuss";
          key = "m";
        }
        {
          name = "Qubes Announcements";
          folder = "/ruby-srxl/qubes-announce";
          key = "q";
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
      weekly-backup = {
        Unit = {
          Description = "Backup user data directory to offsite storage";
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${pkgs.kopia}/bin/kopia --config-file /home/ruby/.config/kopia/remote.config snapshot create /home/ruby";
        };
      };

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
      rescrobbled = {
        Unit = {
          Description = "An MPRIS scrobbler";
        };
        Service = {
          ExecStart = "${pkgs.rescrobbled}/bin/rescrobbled";
          Restart = "on-failure";
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
      solaar = {
        Unit = {
          Description = "Control software for Logitech devices";
        };
        Service = {
          ExecStart = "${pkgs.solaar}/bin/solaar -w hide";
          Restart = "on-failure";
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };

      steam-big-picture = {
        Unit.Description = "Start Steam Big Picture Mode for Sunshine";
        Service = {
          Type = "oneshot";
          ExecStart = "${lib.getExe pkgs.steam} steam://open/bigpicture";
        };
      };
    };

    timers = {
      weekly-backup = {
        Unit = {
          Description = "Backup user data directory to offsite storage every Saturday at 12pm";
        };
        Timer = {
          OnCalendar = "Sat *-*-* 12:00:00";
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    };
  };

  home.stateVersion = "21.05";
}
