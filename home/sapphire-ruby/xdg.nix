{ config, pkgs, ... }:

{
  xdg = {
    desktopEntries = let
      kitty = config.programs.kitty.package;

      script = pkgs.writeShellScript "telnet-url-handler" ''
        IFS=":" read -ra host <<< $(${pkgs.coreutils}/bin/basename $@)
        ${kitty}/bin/kitty nix-shell -p inetutils --run "telnet ''${host[0]} ''${host[1]}"
      '';
    in {
      telnet-handler = {
        name = "Telnet URL Handler";
        type = "Application";
        noDisplay = true;
        mimeType = [ "x-scheme-handler/telnet" ];
        exec = "${script} %u";
      };
    };

    mimeApps = {
      enable = true;
      defaultApplications = {
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];

        "application/json" = [ "emacsclient.desktop" ];
        "application/pdf" = [ "org.pwmt.zathura.desktop" ];
        "application/vnd.microsoft.portable-executable" = [ "wine.desktop" ];
        "application/x-xz" = [ "org.gnome.FileRoller.desktop" ];
        "application/zip" = [ "org.gnome.FileRoller.desktop" ];

        "audio/flac" = [ "vlc.desktop" ];
        "audio/mpeg" = [ "vlc.desktop" ];
        "audio/x-wav" = [ "vlc.desktop" ];

        "image/bmp" = [ "imv.desktop" ];
        "image/gif" = [ "imv.desktop" ];
        "image/jpeg" = [ "imv.desktop" ];
        "image/png" = [ "imv.desktop" ];
        "image/vnd.adobe.photoshop" = [ "gimp.desktop" ];
        "image/webp" = [ "imv.desktop" ];
        "image/x-xcf" = [ "gimp.desktop" ];

        "text/html" = [ "firefox.desktop" ];
        "text/plain" = [ "emacsclient.desktop" ];
        "text/x-lisp" = [ "firefox.desktop" ];
        "text/xml" = [ "emacsclient.desktop" ];

        "video/mp4" = [ "mpv.desktop" ];
        "video/quicktime" = [ "mpv.desktop" ];
        "video/webm" = [ "mpv.desktop" ];
        "video/x-matroska" = [ "mpv.desktop" ];
      };
    };
    userDirs = {
      enable = true;
      desktop = "$HOME/.desktop";
      documents = "$HOME/misc";
      download = "$HOME/download";
      music = "$HOME/media/Library/Music";
      pictures = "$HOME/img";
    };
  };
}
