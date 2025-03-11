{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}:

let
  mkFirefoxModule = import "${modulesPath}/programs/firefox/mkFirefoxModule.nix";
in
{
  imports = [
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

  home.sessionVariables.BROWSER = lib.getExe config.programs.zen-browser.package;

  programs.zen-browser = {
    enable = true;
    profiles.Default = {
      id = 0;
      isDefault = true;
      name = "default";
      path = "default";
      extensions.packages =
        with pkgs.nur.repos.rycee.firefox-addons;
        with pkgs;
        [
          bitwarden
          decentraleyes
          firefox-color
          frankerfacez
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
    };
  };

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
}
