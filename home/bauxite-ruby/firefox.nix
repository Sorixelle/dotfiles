{ config, pkgs, ... }:

{
  home.sessionVariables.BROWSER = "${config.programs.firefox.package}/bin/firefox";

  programs.firefox = {
    enable = true;
    package = pkgs.firefox-unwrapped;
    profiles.Default = {
      id = 0;
      isDefault = true;
      name = "Default";
      path = "default";
      extensions.packages =
        with pkgs.nur.repos.rycee.firefox-addons;
        with pkgs;
        [
          # TODO: not on darwin?
          # bitwarden
          decentraleyes
          firefox-color
          frankerfacez
          kagi-search
          multi-account-containers
          old-reddit-redirect
          react-devtools
          reddit-enhancement-suite
          return-youtube-dislikes
          sidebery
          sponsorblock
          stylus
          tridactyl
          tubearchivist-companion
          ublock-origin
          violentmonkey
        ];
    };
  };
}
