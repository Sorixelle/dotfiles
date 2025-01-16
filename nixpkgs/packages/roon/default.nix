{
  lib,
  makeDesktopItem,
  wineWowPackages,
  writeShellScript,

  wineprefix ? "/home/ruby/wineprefixes/roon",
}:

makeDesktopItem {
  name = "roon";
  desktopName = "Roon";
  icon = ./icon.png;
  categories = [
    "Audio"
    "AudioVideo"
    "Player"
  ];
  startupNotify = true;
  startupWMClass = "roon.exe";

  exec = writeShellScript "roon" ''
    env WINEPREFIX=${wineprefix} WINEDLLOVERRIDES="windows.media.mediacontrol=" ${lib.getExe wineWowPackages.staging} ${wineprefix}/drive_c/users/ruby/AppData/Local/Roon/Application/Roon.exe -scalefactor=1.0
  '';
}
