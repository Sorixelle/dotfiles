{
  makeDesktopItem,
  lib,
  ghostty,
  senpai,
}:

makeDesktopItem {
  name = "senpai";
  desktopName = "Senpai";
  genericName = "IRC Client";
  icon = "${senpai.src}/res/icon.128.png";
  categories = [
    "Network"
    "InstantMessaging"
    "Chat"
    "IRCClient"
    "ConsoleOnly"
  ];
  startupNotify = true;
  exec = "${lib.getExe ghostty} --class=app.senpai -e ${lib.getExe senpai}";
}
