{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    acousticbrainz-gui
    audacity
    bless
    cachix
    calibre
    darktable
    discord
    dunst
    element-desktop
    evince
    ffmpeg-full
    fusee-launcher
    gimp
    gnome3.eog
    gnome3.file-roller
    gnome3.gedit
    insomnia
    ipmitool
    libreoffice-fresh
    keepassxc
    magic-wormhole
    moserial
    mullvad-vpn
    neofetch
    pavucontrol
    picard
    polymc
    python3
    remmina
    rnix-lsp
    shutter
    sshfs
    steam
    steam-run
    spek
    transmission-gtk
    trezor_agent
    trezorctl
    veracrypt
    virt-manager
    virt-viewer
    vlc
    wineWowPackages.staging
    winetricks
    xorg.xkill
    xfce.thunar
    xfce.xfconf
  ];

  imports = [ ./modules/common-linux.nix ];

  home.sessionVariables = {
    BROWSER = "${config.programs.firefox.package}/bin/firefox";
    EDITOR = "${pkgs.vim}/bin/vim";
  };

  manual.html.enable = true;

  programs = {
    chromium = {
      enable = true;
      package = pkgs.ungoogled-chromium;
    };

    direnv = {
      enable = true;
      enableFishIntegration = true;
      nix-direnv.enable = true;
    };

    firefox = {
      enable = true;
      package = pkgs.firefox;
      extensions = with pkgs.nur.repos.rycee.firefox-addons;
        with pkgs; [
          decentraleyes
          firefox-color
          frankerfacez
          https-everywhere
          keepassxc-browser
          metamask
          multi-account-containers
          privacy-badger
          react-devtools
          reddit-enhancement-suite
          sidebery
          tridactyl
          ublock-origin
          violentmonkey
        ];
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
        key = "12BFCA4D4B2EE0EB";
        signByDefault = true;
      };
    };

    gpg = {
      enable = true;
      settings = { keyserver = "hkps://keys.openpgp.org"; };
    };

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
  };

  services = {
    easyeffects.enable = true;
    udiskie.enable = true;

    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      pinentryFlavor = "gnome3";
    };
  };

  srxl.theme.onedark.enable = true;

  systemd.user = {
    services = {
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
