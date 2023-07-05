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
    ./waybar.nix
  ];

  home.packages = with pkgs; [
    _3dsconv
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
    fbi-servefiles
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
    nil
    nix-prefetch-scripts
    nmap
    pavucontrol
    perlPackages.ArchiveZip # crc32 command-line utility
    picard
    plexamp
    prismlauncher
    python3
    qbittorrent
    ranger
    remmina
    scr
    steam
    steam-run
    spek
    trash-cli
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
      name = "Catppuccin-Macchiato-Standard-Teal-dark";
      package = pkgs.catppuccin-gtk.override {
        variant = "macchiato";
        tweaks = [ "rimless" ];
        accents = [ "teal" ];
      };
    };
  };

  manual.html.enable = true;

  programs = {
    autojump.enable = true;

    bash.enable = true;

    chromium = {
      enable = true;
      package = pkgs.chromium;
      extensions = [
        { id = "cmpdlhmnmjhihmcfnigoememnffkimlk"; } # Catppuccin Theme
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
      server.enable = true;
      package = pkgs.emacs-git;
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
        Unit = { Description = "Backup user data directory to local NAS"; };
        Service = {
          Type = "oneshot";
          ExecStart = "${pkgs.kopia}/bin/kopia snapshot create /home/ruby/usr";
        };
      };
      weekly-backup = {
        Unit = {
          Description = "Backup user data directory to offsite storage";
        };
        Service = {
          Type = "oneshot";
          ExecStart =
            "${pkgs.kopia}/bin/kopia --config-file /home/ruby/.config/kopia/remote.config snapshot create /home/ruby/usr";
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
          Description =
            "Backup user data directory to local NAS every night at 6pm";
        };
        Timer = { OnCalendar = "18:00:00"; };
        Install = { WantedBy = [ "graphical-session.target" ]; };
      };
      weekly-backup = {
        Unit = {
          Description =
            "Backup user data directory to offsite storage every Saturday at 12pm";
        };
        Timer = { OnCalendar = "Sat *-*-* 12:00:00"; };
        Install = { WantedBy = [ "graphical-session.target" ]; };
      };
    };
  };

  xdg = {
    configFile = {
      "neofetch/config.conf".text = ''
        print_info() {
          info "" distro
          info "󰍹" de
          info "󰉼" theme
          info "" term
          info "" cpu
          info "󰘚" memory
          info cols
        }

        distro_shorthand="on"
        os_arch="off"
        memory_unit="gib"
        shell_version="off"
        cpu_speed="off"
        cpu_cores="off"
        gpu_type="dedicated"
        gtk_shorthand="on"
        separator=" "
        block_width=3
        image_backend="kitty"
        image_source="${./img/fetch.png}"
        image_size="15%"
      '';

      "ranger/rc.conf".text = ''
        set preview_images_method kitty
      '';
      "ranger/rifle.conf".text = ''
        ext x?html?, flag f = ${config.programs.firefox.package}/bin/firefox -- "$@"

        mime ^text, label editor = ''${VISUAL:-$EDITOR} -- "$@"
        mime ^text, label pager  = $PAGER -- "$@"

        ext pdf|djvu|epub|cb[rz], flag f = ${pkgs.zathura}/bin/zathura -- "$@"
        ext pptx?|od[dfgpst]|docx?|sxc|xlsx?|xlt|xlw|gnm|gnumeric, flag f = ${pkgs.libreoffice-fresh}/bin/libreoffice "$@"
        ext xcf, flag f = ${pkgs.gimp}/bin/gimp -- "$@"

        mime ^image, flag f = ${pkgs.imv}/bin/imv -- "$@"
        mime ^video|^audio, flag f = ${pkgs.vlc}/bin/vlc -- "$@"

        label open, flag f = ${pkgs.xdg-utils}/bin/xdg-open "$@"

        label trash = ${pkgs.trash-cli}/bin/trash-put "$@"
      '';
    };

    mimeApps = {
      enable = true;
      defaultApplications = {
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];

        "application/pdf" = [ "org.gnome.Evince.desktop" ];
        "application/zip" = [ "org.gnome.FileRoller.desktop" ];
        "image/jpeg" = [ "org.gnome.eog.desktop" ];
        "image/png" = [ "org.gnome.eog.desktop" ];
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
