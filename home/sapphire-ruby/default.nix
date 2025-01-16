{ pkgs, lib, ... }:

{
  imports = [
    ../modules/common.nix

    ./dunst.nix
    ./firefox.nix
    ./fish.nix
    ./kitty.nix
    ./rofi.nix
    ./starship.nix
    ./sway.nix
    ./xdg.nix
  ];

  home.packages = with pkgs; [
    audacity
    (aspellWithDicts (
      dicts: with dicts; [
        en
        en-computers
        en-science
      ]
    ))
    betterdiscordctl
    bitwarden
    bitwarden-cli
    calibre
    cinny-desktop
    darktable
    discord
    ffmpeg-full
    file-roller
    gimp
    git-diffie
    imv
    inetutils
    jump
    libreoffice-fresh
    mpv
    nix-prefetch-scripts
    nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted
    osu-lazer-bin
    pavucontrol
    picard
    plexamp
    prismlauncher
    python3
    qbittorrent
    roon-launcher
    rs-git-fsmonitor
    scr
    solaar
    steam
    virt-manager
    vlc
    winbox
    wineWowPackages.staging
    winetricks
    wireshark
    xfce.thunar
    xfce.xfconf
    xsane
    zathura
    zulip
  ];

  gtk = {
    enable = true;
    cursorTheme = {
      name = "catppuccin-macchiato-teal-cursors";
      package = pkgs.catppuccin-cursors.macchiatoTeal;
    };
    iconTheme = {
      name = "Arc";
      package = pkgs.arc-icon-theme;
    };
    theme = {
      name = "catppuccin-macchiato-teal-standard+rimless";
      package = pkgs.catppuccin-gtk.override {
        variant = "macchiato";
        tweaks = [ "rimless" ];
        accents = [ "teal" ];
      };
    };
  };

  manual.html.enable = true;

  programs = {
    bash.enable = true;

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

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    git = {
      enable = true;
      package = pkgs.gitAndTools.gitFull;
      lfs.enable = true;
      userEmail = "ruby@srxl.me";
      userName = "Ruby Iris Juric";
      signing = {
        key = "B6D7116C451A5B41";
        signByDefault = true;
      };
      extraConfig.core.fsmonitor = "${pkgs.rs-git-fsmonitor}/bin/rs-git-fsmonitor";
    };

    gpg = {
      enable = true;
      settings = {
        keyserver = "hkps://keys.openpgp.org";
      };
      scdaemonSettings = {
        disable-ccid = true;
      };
    };

    mbsync.enable = true;

    mu.enable = true;

    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        obs-pipewire-audio-capture
        wlrobs
      ];
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
  };

  services = {
    easyeffects = {
      enable = true;
      preset = "DT880";
    };

    udiskie.enable = true;

    wlsunset = {
      enable = true;
      latitude = -37.8;
      longitude = 145;
      systemdTarget = "sway-session.target";
      temperature = {
        day = 6500;
        night = 3000;
      };
    };

    gpg-agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-gnome3;
    };
  };

  srxl = {
    emacs = {
      enable = true;
      server.enable = true;
      package = pkgs.emacs-pgtk;
      theme = "catppuccin";
      extraConfig = ''
        (setq catppuccin-flavor 'macchiato)
      '';
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
