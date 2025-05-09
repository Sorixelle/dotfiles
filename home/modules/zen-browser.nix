{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}:

let
  mkFirefoxModule = import "${modulesPath}/programs/firefox/mkFirefoxModule.nix";

  catppuccinThemePath =
    let
      themes = (import ../../npins).catppuccin-zen-browser;
      capitalize =
        str: (lib.toUpper (lib.substring 0 1 str)) + (lib.substring 1 (lib.stringLength str) str);
      inherit (config.catppuccin) accent flavor;
    in
    "${themes}/themes/${capitalize flavor}/${capitalize accent}";
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
        configPath = ".zen";
        vendorPath = ".zen";
      };
    })
  ];

  options.srxl.zen-browser = {
    catppuccin.enable = lib.mkEnableOption "catppuccin theming for zen-browser";
  };

  config = {
    programs.zen-browser = {
      enable = true;
      nativeMessagingHosts = [
        pkgs.kdePackages.plasma-browser-integration
        pkgs.tridactyl-native
      ];
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
          plasma-integration
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
        userChrome = lib.mkIf config.srxl.zen-browser.catppuccin.enable (
          builtins.readFile "${catppuccinThemePath}/userChrome.css"
        );
        userContent = lib.mkIf config.srxl.zen-browser.catppuccin.enable (
          builtins.readFile "${catppuccinThemePath}/userContent.css"
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
    services.dunst.settings.global.browser = lib.getExe config.programs.zen-browser.package;

    # Add the icon from the Catppuccin theme if configured
    home.file.zenBrowserThemeIcon = lib.mkIf config.srxl.zen-browser.catppuccin.enable {
      target = ".zen/default/chrome/zen-logo-${config.catppuccin.flavor}.svg";
      source = "${catppuccinThemePath}/zen-logo-${config.catppuccin.flavor}.svg";
    };

    # Need to override this, because Zen requires a ZenAvatarPath in a profile and home-manager has no way to set that
    home.file.".zen/profiles.ini" = lib.mkForce {
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
