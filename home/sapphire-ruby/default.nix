{ pkgs, ... }:

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
    ./xdg.nix
  ];

  home.packages = with pkgs; [
    _3dsconv
    audacity
    betterdiscordctl
    bitwarden
    bitwarden-cli
    bless
    cachix
    ctrtool
    cutentr
    darktable
    discord
    element-desktop
    fbi-servefiles
    ffmpeg-full
    gimp
    gnome.file-roller
    igir
    imv
    inetutils
    jump
    libreoffice-fresh
    liquidctl
    lm_sensors
    kopia
    magic-wormhole
    makerom
    moserial
    mpv
    mtr
    neofetch
    nheko
    nil
    nix-prefetch-scripts
    nmap
    nodePackages.typescript-language-server
    nodePackages.vscode-css-languageserver-bin
    nodePackages.vscode-html-languageserver-bin
    pavucontrol
    perlPackages.ArchiveZip # crc32 command-line utility
    picard
    plexamp
    plex-media-player
    prismlauncher
    python3
    qbittorrent
    remmina
    rs-git-fsmonitor
    scr
    solaar
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
    yt-dlp
    yubikey-manager
    zathura
    zotero
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
      extraConfig.core.fsmonitor =
        "${pkgs.rs-git-fsmonitor}/bin/rs-git-fsmonitor";
    };

    gpg = {
      enable = true;
      # BUG: GnuPG 2.4.4 fixes some important bugs
      # https://github.com/NixOS/nixpkgs/pull/284778
      package = pkgs.gnupg24.overrideAttrs (old: {
        version = "2.4.4";
        src = pkgs.fetchurl {
          url = "mirror://gnupg/gnupg/gnupg-2.4.4.tar.bz2";
          hash = "sha256-Z+vgFsqQ+naIzmejh+vYLGJh6ViX23sj3yT/M1voW8Y=";
        };
      });
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

    gammastep = {
      enable = true;
      provider = "geoclue2";
    };

    gpg-agent = {
      enable = true;
      pinentryFlavor = "gnome3";
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
      # nightly-backup = {
      #   Unit = { Description = "Backup user data directory to local NAS"; };
      #   Service = {
      #     Type = "oneshot";
      #     ExecStart = "${pkgs.kopia}/bin/kopia snapshot create /home/ruby/usr";
      #   };
      # };
      weekly-backup = {
        Unit = {
          Description = "Backup user data directory to offsite storage";
        };
        Service = {
          Type = "oneshot";
          ExecStart =
            "${pkgs.kopia}/bin/kopia --config-file /home/ruby/.config/kopia/remote.config snapshot create /home/ruby";
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
      rescrobbled = {
        Unit = { Description = "An MPRIS scrobbler"; };
        Service = {
          ExecStart = "${pkgs.rescrobbled}/bin/rescrobbled";
          Restart = "on-failure";
        };
        Install = { WantedBy = [ "graphical-session.target" ]; };
      };
      solaar = {
        Unit = { Description = "Control software for Logitech devices"; };
        Service = {
          ExecStart = "${pkgs.solaar}/bin/solaar -w hide";
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
    };
  };

  home.stateVersion = "21.05";
}
