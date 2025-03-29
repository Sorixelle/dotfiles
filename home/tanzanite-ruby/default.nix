{ pkgs, ... }:

{
  imports = [
    ../modules/common.nix
    ../modules/desktop-theme.nix
    ../modules/dunst.nix
    ../modules/kitty.nix
    ../modules/rofi.nix
    ../modules/xdg.nix
    ../modules/zen-browser.nix

    ./locking.nix
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

  manual.html.enable = true;

  catppuccin = {
    flavor = "frappe";
    accent = "lavender";
  };

  srxl.zen-browser.catppuccin.enable = true;

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
