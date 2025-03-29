{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Install some programs for viewing various files
  home.packages = with pkgs; [
    file-roller
    imv
    mpv
    vlc
    zathura
  ];

  xdg = {
    desktopEntries =
      let
        # Script for opening telnet URLs in a terminal window
        # Only thing I'm aware of that does this is EVE-NG: https://www.eve-ng.net/
        script = pkgs.writeShellScript "telnet-url-handler" ''
          IFS=":" read -ra host <<< $(${pkgs.coreutils}/bin/basename $@)
          ${lib.getExe config.programs.kitty.package} --class=kitty-telnet-handler "${pkgs.inetutils}/bin/telnet ''${host[0]} ''${host[1]}"
        '';
      in
      {
        # Register the URL handler
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
      # Default associations for file formats
      defaultApplications = {
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

        "text/plain" = [ "emacsclient.desktop" ];
        "text/xml" = [ "emacsclient.desktop" ];

        "video/mp4" = [ "mpv.desktop" ];
        "video/quicktime" = [ "mpv.desktop" ];
        "video/webm" = [ "mpv.desktop" ];
        "video/x-matroska" = [ "mpv.desktop" ];
      };
    };

    # Set standard home directory paths
    userDirs = {
      enable = true;
      desktop = "$HOME/.desktop"; # hidden, don't use it
      documents = lib.mkDefault "$HOME/misc";
      download = lib.mkDefault "$HOME/download";
      music = lib.mkDefault "$HOME/music";
      pictures = lib.mkDefault "$HOME/img";
    };
  };
}
