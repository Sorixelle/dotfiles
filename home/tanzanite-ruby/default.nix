{ pkgs, ... }:

{
  imports = [
    ../modules/common.nix
    ../modules/xdg.nix
    ../modules/zen-browser.nix

    ./dunst.nix
    ./firefox.nix
    ./fish.nix
    ./kitty.nix
    ./locking.nix
    ./rofi.nix
    ./starship.nix
    ./sway.nix
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
    git-diffie
    jump
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

  gtk = with pkgs; {
    enable = true;
    cursorTheme = {
      name = "catppuccin-frappe-mauve-cursors";
      package = pkgs.catppuccin-cursors.frappeMauve;
    };
    iconTheme = {
      name = "Arc";
      package = arc-icon-theme;
    };
    theme = {
      name = "catppuccin-frappe-mauve-standard+rimless";
      package = pkgs.catppuccin-gtk.override {
        variant = "frappe";
        tweaks = [ "rimless" ];
        accents = [ "mauve" ];
      };
    };
  };

  manual.html.enable = true;

  srxl = {
    zen-browser.catppuccin = {
      enable = true;
      variant = "Frappe";
      accent = "Lavender";
    };
  };

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
        format = "ssh";
        key = "~/.ssh/id_ed25519_sk";
        signByDefault = true;
      };
      extraConfig = {
        core.fsmonitor = "${pkgs.rs-git-fsmonitor}/bin/rs-git-fsmonitor";
        init.defaultBranch = "main";
      };
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

    tealdeer.enable = true;
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
  };

  services = {
    gpg-agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-gnome3;
    };

    mpris-proxy.enable = true;

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
  };

  srxl = {
    emacs = {
      enable = true;
      server.enable = true;
      package = pkgs.emacs-unstable-pgtk;
      theme = "catppuccin";
      extraConfig = ''
        (setq catppuccin-flavor 'frappe)
      '';
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
