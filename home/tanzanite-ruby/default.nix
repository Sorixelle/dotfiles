{ pkgs, ... }:

{
  imports = [
    ../modules/common-linux.nix

    ./firefox.nix
    ./fish.nix
    ./hyprland.nix
    ./kitty.nix
    ./rofi.nix
    ./starship.nix
    ./xdg.nix
  ];

  home.packages = with pkgs; [
    (aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))
    betterdiscordctl
    bitwarden
    discord
    element-desktop
    ffmpeg-full
    gimp
    gnome.file-roller
    imv
    jump
    libreoffice-fresh
    magic-wormhole
    mpv
    mtr
    nix-prefetch-scripts
    nmap
    pavucontrol
    plexamp
    plex-media-player
    python3
    solaar
    vlc
    wineWowPackages.staging
    winetricks
    xfce.thunar
    xfce.xfconf
    yt-dlp
    yubikey-manager
    zathura
  ];

  gtk = with pkgs; {
    enable = true;
    cursorTheme = {
      name = "Catppuccin-Frappe-Mauve-Cursors";
      package = pkgs.catppuccin-cursors.frappeMauve;
    };
    iconTheme = {
      name = "Arc";
      package = arc-icon-theme;
    };
    theme = {
      name = "Catppuccin-Frappe-Standard-Mauve-Dark";
      package = pkgs.catppuccin-gtk.override {
        variant = "frappe";
        tweaks = [ "rimless" ];
        accents = [ "mauve" ];
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
      settings = { keyserver = "hkps://keys.openpgp.org"; };
      scdaemonSettings = { disable-ccid = true; };
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
        (setq catppuccin-flavor 'frappe)
      '';
    };

    fonts = let
      nerdfonts =
        pkgs.nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; };
    in {
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
        nerdfonts
        noto-fonts-cjk
      ];
    };
  };

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

  home.stateVersion = "23.11";
}
