{
  config,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    betterdiscordctl
    discord
  ];

  xdg.configFile =
    let
      themeFlavor = config.catppuccin.flavor;

      catppuccin-theme = (import ../../npins).catppuccin-discord;
    in
    {
      "BetterDiscord/themes/catppuccin.theme.css".source =
        "${catppuccin-theme}/themes/${themeFlavor}.theme.css";

      "BetterDiscord/plugins/Pluralchum.plugin.js".source = pkgs.fetchurl {
        url = "https://github.com/estroBiologist/pluralchum/releases/download/2.6.0/Pluralchum.plugin.js";
        hash = "sha256-R9OaVKXp0diyCVgk2hLLJYP3gb3VbN7zUVHpiIBCmyw=";
      };
    };
}
