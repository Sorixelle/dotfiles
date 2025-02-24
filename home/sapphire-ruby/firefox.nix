{ config, pkgs, ... }:

{
  home.sessionVariables.BROWSER = "${config.programs.firefox.package}/bin/firefox";

  programs.firefox = {
    enable = true;
    package = pkgs.firefox.override {
      nativeMessagingHosts = [ pkgs.tridactyl-native ];
    };
    profiles.Default = {
      id = 0;
      isDefault = true;
      name = "Default";
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
