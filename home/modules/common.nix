{ pkgs, ... }:

{
  imports = [
    ./emacs.nix
    ./email.nix
    ./fonts.nix
    ./shell.nix
    ./starship.nix
  ];

  # Generate HTML home-manager manual for options reference
  manual.html.enable = true;

  # Place the repo's nixpkgs config in the globally-accessible location
  xdg.configFile."nixpkgs/config.nix".source = ../../nixpkgs/config.nix;

  # Enable Catppuccin theming for common tools
  catppuccin = {
    bat.enable = true;
    glamour.enable = true;
    nvim.enable = true;
  };

  # And let home-manager manage the config for them
  programs = {
    bat.enable = true;
    neovim.enable = true;

    # Load Direnv into all shells, and setup nix-direnv
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    git = {
      enable = true;
      package = pkgs.gitAndTools.gitFull;

      lfs.enable = true;

      # it me
      userEmail = "ruby@srxl.me";
      userName = "Ruby Iris Juric";

      # Sign commits with my SSH key stored on my Yubikey
      signing = {
        format = "ssh";
        key = "~/.ssh/id_ed25519_sk";
        signByDefault = true;
      };

      extraConfig = {
        # Setup rs-git-fsmonitor to help performance in large repos
        core.fsmonitor = "${pkgs.rs-git-fsmonitor}/bin/rs-git-fsmonitor";

        init.defaultBranch = "main";
      };
    };

    # Configure GnuPG for use with my Yubikey
    gpg = {
      enable = true;
      settings = {
        keyserver = "hkps://keys.openpgp.org";
      };
      scdaemonSettings = {
        disable-ccid = true;
      };
    };

    # Enable tealdeer for brief command line cheatsheets
    tealdeer.enable = true;
  };

  services = {
    # Setup gpg-agent for pinentry whenever my Yubikey GPG password is needed
    gpg-agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-gnome3;
    };

    # Setup udiskie for removable disk management
    udiskie.enable = true;

    # Add wlsunset for blue-light filtering at night
    wlsunset = {
      enable = true;
      latitude = -37.8;
      longitude = 145;
      temperature = {
        day = 6500;
        night = 3000;
      };
    };
  };
}
