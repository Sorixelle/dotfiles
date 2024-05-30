{ lib, fetchFromGitHub, fetchurl

, makeDesktopItem, symlinkJoin, writeShellScriptBin

, python3, qt5 }:

let
  pname = "tinfoil-nut";
  version = "3.3";

  nutSource = fetchFromGitHub {
    owner = "blawar";
    repo = "nut";
    rev = "5cf47cd73704fd89c27c5fdafbbb0ad5e5053915";
    hash = "sha256-dVE8tvuPXhJTdnekpfomPn0EUwVV7hvEvLf3KEEUazc=";
  };

  pycryptoplus = python3.pkgs.buildPythonPackage rec {
    pname = "pycryptoplus";
    version = "0.0.1";
    propagatedBuildInputs = with python3.pkgs; [ pycryptodome ];
    src = python3.pkgs.fetchPypi {
      inherit pname version;
      hash = "sha256-BnBAuUgr1bj3jABJIjwsL+ogtOcnUe6CqelX+bQyypQ=";
    };
  };
  qt-range-slider = python3.pkgs.buildPythonPackage rec {
    pname = "qt-range-slider";
    version = "0.2.7";
    propagatedBuildInputs = with python3.pkgs; [ pyqt5 ];
    src = python3.pkgs.fetchPypi {
      inherit pname version;
      hash = "sha256-KcEWFAaxRy/aXdW05p1PRn1vqnAjFEsqCiPYgqVsNM8=";
    };
    doCheck = false;
  };
  pythonEnv = python3.withPackages (ps:
    with ps; [
      asn1
      beautifulsoup4
      certifi
      colorama
      filelock
      flask
      future
      google-api-python-client
      google-auth-oauthlib
      humanize
      markupsafe
      pillow
      pycryptodome
      pycryptoplus
      pycurl
      pyopenssl
      pyqt5
      pyusb
      qt-range-slider
      requests
      tqdm
      unidecode
      urllib3
      watchdog
      zstandard
    ]);

  makeWrapper = outname: scriptname:
    writeShellScriptBin outname ''
      export APPDIR="''${XDG_DATA_HOME:-"''${HOME}/.local/share"}/nut"
      mkdir -p $APPDIR
      cp -r ${nutSource}/* $APPDIR
      chmod -R u+w $APPDIR

      cd $APPDIR
      ${lib.getExe pythonEnv} ${scriptname} $@
    '';

  nut = makeWrapper "nut" "nut.py";
  nutGui = makeWrapper "nut-gui" "nut_gui.py";

  nutGuiDesktop = makeDesktopItem {
    name = "nut-gui";
    desktopName = "NUT";
    comment = "Nintendo Switch title manager";
    exec = "nut-gui";
    icon = "nut-gui";
    categories = [ "Network" "Utility" ];
    startupWMClass = "python3";
  };

  nutGuiIcon = fetchurl {
    name = "nut-gui.png";
    url = "https://tinfoil.io/images/release.png";
    hash = "sha256-VLzMZK3e+9qDOcbmfc8URaGU57t34D1OsdiUz8NYxGQ=";
  };
in symlinkJoin {
  name = "${pname}-${version}";
  paths = [ nut nutGui nutGuiDesktop ];

  nativeBuildInputs = [ qt5.wrapQtAppsHook ];
  buildInputs = [ qt5.qtbase ];

  postBuild = ''
    wrapQtApp "$out/bin/nut-gui"
    mkdir -p "$out/share/pixmaps"
    ln -s "${nutGuiIcon}" "$out/share/pixmaps/nut-gui.png"
  '';

  meta = with lib; {
    description = "Nintendo Switch title manager, for use with Tinfoil";
    homepage = "https://github.com/blawar/nut";
    downloadPage = "https://github.com/blawar/nut/releases/latest";
    changelog = "https://github.com/blawar/nut/releases";
    license = licenses.gpl3Only;
    mainProgram = "nut";
    platforms = platforms.linux ++ platforms.darwin;
  };
}
