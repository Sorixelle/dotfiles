{ config, pkgs, ... }:

{
  imports = [
    ../modules/common-linux.nix

    ./dunst.nix
    ./email.nix
    ./firefox.nix
    ./fish.nix
    ./hyprland.nix
    ./kitty.nix
    ./rofi.nix
    ./starship.nix
  ];

  home.packages = with pkgs; [
    audacity
    betterdiscordctl
    bless
    cachix
    calibre
    ctrtool
    cutentr
    darktable
    discord
    evince
    ffmpeg-full
    gimp
    gnome.eog
    gnome.file-roller
    igir
    insomnia
    libreoffice-fresh
    liquidctl
    lm_sensors
    keepassxc
    kopia
    magic-wormhole
    makerom
    moserial
    mullvad-vpn
    mtr
    neofetch
    nheko
    nix-prefetch-scripts
    nmap
    pavucontrol
    perlPackages.ArchiveZip # crc32 command-line utility
    picard
    plexamp
    prismlauncher
    python3
    qbittorrent
    remmina
    rnix-lsp
    scr
    steam
    steam-run
    spek
    virt-manager
    vlc
    winbox
    wineWowPackages.staging
    winetricks
    wireshark
    xfce.thunar
    xfce.xfconf
    yubikey-manager
  ];

  gtk = with pkgs; {
    enable = true;
    iconTheme = {
      name = "Arc";
      package = arc-icon-theme;
    };
    theme = {
      name = "Catppuccin-Macchiato-Standard-Teal-Dark";
      package = pkgs.catppuccin-gtk.override {
        variant = "macchiato";
        tweaks = [ "rimless" ];
        accents = [ "teal" ];
      };
    };
  };

  home.sessionVariables.EDITOR = "${pkgs.vim}/bin/vim";

  manual.html.enable = true;

  programs = {
    chromium = {
      enable = true;
      package = pkgs.chromium;
      extensions = [
        { id = "ldpochfccmkkmhdbclfhpagapcfdljkj"; } # Decentraleyes
        { id = "oboonakemofpalcgghocfoadofidjkkk"; } # KeePassXC Browser
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
    };

    gpg = {
      enable = true;
      settings = { keyserver = "hkps://keys.openpgp.org"; };
      scdaemonSettings = { disable-ccid = true; };
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
    platformTheme = "gtk";
  };

  services = {
    udiskie.enable = true;

    gpg-agent = {
      enable = true;
      pinentryFlavor = "gnome3";
    };

    syncthing.enable = true;
  };

  srxl = {
    emacs = {
      enable = true;
      # package = pkgs.emacsGit;
      theme = "catppuccin";
      extraConfig = ''
        (setq catppuccin-flavor 'macchiato)
      '';
    };

    fonts = let
      nerdfonts = pkgs.nerdfonts.override {
        fonts = [ "IBMPlexMono" "NerdFontsSymbolsOnly" ];
      };
    in {
      monospace = {
        name = "IBM Plex Mono";
        size = 12;
        package = pkgs.ibm-plex;
      };
      ui = {
        name = "Inter";
        size = 12;
        package = pkgs.inter;
      };
      serif = {
        name = "IBM Plex Serif";
        size = 12;
        package = pkgs.ibm-plex;
      };
      extraFonts = with pkgs; [
        emacs-all-the-icons-fonts
        nerdfonts
        noto-fonts-cjk
      ];
    };
  };

  systemd.user = {
    services = {
      nightly-backup = {
        Unit = { Description = "Backup user data directory to NAS"; };
        Service = {
          Type = "oneshot";
          ExecStart = "${pkgs.kopia}/bin/kopia snapshot create /home/ruby/usr";
        };
      };

      polkit-gnome = {
        Unit = { Description = "GNOME Polkit authentication agent"; };
        Service = {
          ExecStart =
            "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
        };
        Install = { WantedBy = [ "graphical-session.target" ]; };
      };
    };

    timers = {
      nightly-backup = {
        Unit = {
          Description = "Backup user data directory to NAS every night at 6pm";
        };
        Timer = { OnCalendar = "18:00:00"; };
        Install = { WantedBy = [ "graphical-session.target" ]; };
      };
    };
  };

  xdg = {
    mimeApps = {
      enable = true;
      defaultApplications = {
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
      };
    };
    userDirs = {
      enable = true;
      documents = "$HOME/usr/misc";
      download = "$HOME/usr/download";
      music = "$HOME/usr/music";
      pictures = "$HOME/usr/img";
    };
  };

  home.stateVersion = "21.05";
}
