{ config, pkgs, ... }:

{
  home.sessionVariables.BROWSER =
    "${config.programs.firefox.package}/bin/firefox";

  programs.firefox = {
    enable = true;
    package =
      pkgs.firefox.override { cfg = { enableTridactylNative = true; }; };
    profiles.Default = {
      id = 0;
      isDefault = true;
      name = "Default";
      path = "default";
      extensions = with pkgs.nur.repos.rycee.firefox-addons;
        with pkgs; [
          decentraleyes
          firefox-color
          frankerfacez
          keepassxc-browser
          multi-account-containers
          old-reddit-redirect
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
}
