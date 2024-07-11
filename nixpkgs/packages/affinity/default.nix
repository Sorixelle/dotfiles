# Adaptation of https://codeberg.org/wanesty/affinity-wine-docs/src/branch/guide-wine8.14
# If you pinch this, you'll need to do the iniital setup yourself (and maybe change wineprefix paths)

{ fetchFromGitLab, wineWowPackages, makeDesktopItem, writeShellScript }:

let
  wineAffinity =
    wineWowPackages.staging.overrideAttrs (_: { patches = [ ./wine.patch ]; });

  launchScript = writeShellScript "affinity-app" ''
    export WINEPREFIX=$HOME/wineprefixes/affinity
    export WINEARCH=win64
    ${wineAffinity}/bin/wine "$WINEPREFIX/drive_c/Program Files/Affinity/$1 2/$1.exe"
  '';
in {
  affinity-designer = makeDesktopItem {
    name = "affinity-designer";
    desktopName = "Affinity Designer";
    icon = ./designer.png;
    exec = "${launchScript} Designer";
    categories = [ "Graphics" ];
    mimeTypes = [ "application/x-affinity" "application/afdesign" ];
    startupNotify = true;
    startupWMClass = "designer.exe";
  };

  affinity-photo = makeDesktopItem {
    name = "affinity-photo";
    desktopName = "Affinity Photo";
    icon = ./photo.png;
    exec = "${launchScript} Photo";
    categories = [ "Graphics" ];
    mimeTypes = [ "application/x-affinity" "application/afphoto" ];
    startupNotify = true;
    startupWMClass = "photo.exe";
  };
}
