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
    ./starship.nix
  ];

  home.packages = with pkgs; [
    acousticbrainz-gui
    audacity
    betterdiscordctl
    bless
    cachix
    calibre
    ctrtool
    darktable
    discord
    evince
    feh
    ffmpeg-full
    fusee-launcher
    gimp
    gnome.eog
    gnome.file-roller
    gnome.gedit
    igir
    insomnia
    libreoffice-fresh
    liquidctl
    lm_sensors
    keepassxc
    kopia
    magic-wormhole
    maim
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
    shutter
    steam
    steam-run
    spek
    virt-manager
    vlc
    winbox
    wineWowPackages.staging
    winetricks
    wireshark
    xorg.xkill
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
      name = "Arc-Dark";
      package = arc-theme;
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
      theme = "modus-vivendi-tinted";
    };

    fonts = {
      monospace = {
        name = "Blex Mono NerdFont";
        size = 12;
        package = pkgs.nerdfonts.override { fonts = [ "IBMPlexMono" ]; };
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
      extraFonts = with pkgs; [ emacs-all-the-icons-fonts noto-fonts-cjk ];
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
