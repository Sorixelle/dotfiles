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
          bitwarden
          decentraleyes
          firefox-color
          frankerfacez
          multi-account-containers
          old-reddit-redirect
          privacy-badger
          react-devtools
          reddit-enhancement-suite
          return-youtube-dislikes
          # TODO: some weirdness going on with the 5.0.0 update right now, we'll
          # manage sidebery outside of home-manager until that clears up
          # sidebery
          sponsorblock
          stylus
          tridactyl
          ublock-origin
          violentmonkey
        ];
    };
  };
}
