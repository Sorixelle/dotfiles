{ config, pkgs, ... }:

{
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

  imports = [ ./modules/common-linux.nix ./themes/indev ];

  home.sessionVariables = {
    BROWSER = "${config.programs.firefox.package}/bin/firefox";
    EDITOR = "${pkgs.vim}/bin/vim";
  };

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

    firefox = {
      enable = true;
      package =
        pkgs.firefox.override { cfg = { enableTridactylNative = true; }; };
      profiles.Default = {
        id = 0;
        isDefault = true;
        name = "Default";
        path = "default";
        settings = {
          # https://bugzilla.mozilla.org/show_bug.cgi?id=1679671
          # WebGL seems to be broken without this setting
          "gfx.webrender.all" = true;
          "network.dns.blockDotOnion" = false;
        };
        extensions = with pkgs.nur.repos.rycee.firefox-addons;
          with pkgs; [
            decentraleyes
            firefox-color
            frankerfacez
            keepassxc-browser
            multi-account-containers
            privacy-badger
            react-devtools
            reddit-enhancement-suite
            return-youtube-dislikes
            sidebery
            sponsorblock
            startpage-private-search
            stylus
            tridactyl
            ublock-origin
            violentmonkey
          ];
      };
    };

    fish = {
      enable = true;
      functions = {
        pnpx = {
          description = "Run command from Node package";
          body = ''
            set -l pnpx_command (which pnpx 2> /dev/null)
            if [ -n "$pnpx_command" ]
              $pnpx_command $argv
            else
              nix-shell -p nodePackages.pnpm --run "pnpx $argv"
            end
          '';
        };
      };
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

    ncmpcpp = {
      enable = true;
      package = pkgs.ncmpcpp.override { visualizerSupport = true; };
      settings = {
        visualizer_data_source = "127.0.0.1:10002";
        visualizer_in_stereo = true;
        visualizer_type = "spectrum";
        visualizer_color = "blue, cyan, green, yellow, magenta, red";
        visualizer_fps = 60;
        visualizer_autoscale = true;
        visualizer_spectrum_smooth_look = true;

        song_list_format = "$5{$/b%a - }$b{%t}|{%f}$R{$7(%l)}";
        song_status_format = "{%a - }{%t}|{%f} - {%b}";
        alternative_header_second_line_format =
          "{{$b$5%a $8- $/b}{$6%b}$8{ ($5%N$8)}}|{$5%D}";
        current_item_prefix = "$5$r";
        current_item_suffix = "$/r$9";
        selected_item_prefix = "$3";

        progressbar_look = "─●─";
        user_interface = "alternative";
        data_fetching_delay = true;
        connected_message_on_startup = false;
        cyclic_scrolling = true;
        display_bitrate = true;
        external_editor = "vim";
        mpd_connection_timeout = 60;
      };
    };

    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        obs-pipewire-audio-capture
        wlrobs
      ];
    };

    starship.enableFishIntegration = true;
  };

  services = {
    udiskie.enable = true;

    gpg-agent = {
      enable = true;
      pinentryFlavor = "gnome3";
    };

    mopidy = {
      enable = true;
      extensionPackages = with pkgs; [
        mopidy-mpd
        mopidy-mpris
        mopidy-jellyfin
      ];

      settings = { audio = { output = "pipewiresink"; }; };

      # All the configuration that has passwords and stuff that I obviously
      # can't commit to a public repo goes here
      extraConfigFiles = [ "${config.xdg.configHome}/mopidy/jellyfin.conf" ];
    };

    syncthing.enable = true;
  };

  accounts.email = {
    maildirBasePath = "usr/mail";
    accounts = {
      "ruby@srxl.me" = rec {
        address = "ruby@srxl.me";
        realName = "Ruby Iris Juric";
        gpg.key = "B6D7116C451A5B41";
        primary = true;

        userName = address;
        # TODO: make this not suck balls
        passwordCommand = "cat ~/.email-password";
        imap = {
          host = "imap.migadu.com";
          port = 993;
        };
        smtp = {
          host = "smtp.migadu.com";
          port = 465;
        };

        mbsync = {
          enable = true;
          create = "both";
        };
        mu.enable = true;
      };
    };
  };

  srxl = {
    emacs = {
      enable = true;
      # package = pkgs.emacsGit;
      mu4e = {
        enable = true;
        address = "ruby@srxl.me";
      };
    };
    starship.enable = true;
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

      setup-displays = {
        Unit = { Description = "Configure display settings"; };
        Service = {
          Type = "oneshot";
          ExecStart =
            "${pkgs.xorg.xrandr}/bin/xrandr --output HDMI-A-1 --pos -1920x0 --output DisplayPort-3 --pos 0x0 --primary --mode 2560x1440 --rate 170.00";
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
