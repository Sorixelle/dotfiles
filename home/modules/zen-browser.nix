{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}:

let
  mkFirefoxModule = import "${modulesPath}/programs/firefox/mkFirefoxModule.nix";

  catppuccinThemes = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "zen-browser";
    rev = "b048e8bd54f784d004812036fb83e725a7454ab4";
    hash = "sha256-SoaJV83rOgsQpLKO6PtpTyKFGj75FssdWfTITU7psXM=";
  };

  conf = config.srxl.zen-browser;
in
{
  imports = [
    # Create a programs.zen-browser module, that works like Firefox's but configures Zen instead
    (mkFirefoxModule {
      modulePath = [
        "programs"
        "zen-browser"
      ];
      name = "Zen Browser";
      wrappedPackageName = "zen-browser";
      unwrappedPackageName = "zen-browser-unwrapped";
      visible = true;

      platforms.linux = {
        configPath = ".mozilla/zen";
        vendorPath = ".mozilla";
      };
    })
  ];

  options.srxl.zen-browser =
    let
      inherit (lib) mkEnableOption mkOption types;
    in
    {
      catppuccin = {
        enable = mkEnableOption "catppuccin theming for zen-browser";

        accent = mkOption {
          type = types.enum [
            "Blue"
            "Flamingo"
            "Green"
            "Lavender"
            "Maroon"
            "Mauve"
            "Peach"
            "Pink"
            "Red"
            "Rosewater"
            "Sapphire"
            "Sky"
            "Teal"
            "Yellow"
          ];
          example = "Teal";
          description = ''
            Name of the catppuccin accent colour to use.
          '';
        };
        variant = mkOption {
          type = types.enum [
            "Frappe"
            "Latte"
            "Macchiato"
            "Mocha"
          ];
          example = "Frappe";
          description = ''
            Name of the catppuccin variant to use.
          '';
        };
      };
    };

  config = {
    programs.zen-browser = {
      enable = true;
      profiles.Default = {
        id = 0;
        isDefault = true;
        name = "default";
        path = "default";
        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          bitwarden
          decentraleyes
          multi-account-containers
          kagi-search
          react-devtools
          reddit-enhancement-suite
          redirector
          return-youtube-dislikes
          sponsorblock
          stylus
          tridactyl
          tubearchivist-companion
          ublock-origin
          violentmonkey
        ];

        # Install the Catppuccin themes if configured
        userChrome = lib.mkIf conf.catppuccin.enable (
          builtins.readFile "${catppuccinThemes}/themes/${conf.catppuccin.variant}/${conf.catppuccin.accent}/userChrome.css"
        );
        userContent = lib.mkIf conf.catppuccin.enable (
          builtins.readFile "${catppuccinThemes}/themes/${conf.catppuccin.variant}/${conf.catppuccin.accent}/userContent.css"
        );
      };
    };

    # Set Zen as the default browser
    home.sessionVariables.BROWSER = lib.getExe config.programs.zen-browser.package;
    xdg.mimeApps.defaultApplications = {
      "x-scheme-handler/http" = [ "zen.desktop" ];
      "x-scheme-handler/https" = [ "zen.desktop" ];
      "text/html" = [ "zen.desktop" ];
      "text/x-lisp" = [ "zen.desktop" ];
    };

    # Add the icon from the Catppuccin theme if configured
    home.file.zenBrowserThemeIcon = lib.mkIf conf.catppuccin.enable (
      let
        variant = lib.toLower conf.catppuccin.variant;
      in
      {
        target = ".mozilla/zen/default/chrome/zen-logo-${variant}.svg";
        source = "${catppuccinThemes}/themes/${conf.catppuccin.variant}/${conf.catppuccin.accent}/zen-logo-${variant}.svg";
      }
    );

    # Need to override this, because Zen requires a ZenAvatarPath in a profile and home-manager has no way to set that
    home.file.".mozilla/zen/profiles.ini" = lib.mkForce {
      text = ''
        [General]
        StartWithLastProfile=1
        Version=2

        [Profile0]
        Default=1
        IsRelative=1
        Name=default
        ZenAvatarPath=chrome://browser/content/zen-avatars/avatar-60.svg
        Path=default
      '';
    };
  };
}
