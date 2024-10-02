{
  stdenv,
  fetchFromGitHub,
  cmake,
  essentia-extractor,
  qt5,
}:

stdenv.mkDerivation rec {
  name = "acousticbrainz-gui";
  version = "0.2dev";

  src = fetchFromGitHub {
    owner = "MTG";
    repo = name;
    rev = "360aca397ad7230f102542ea3d67af95b7c8829e";
    sha256 = "1aq9xa2s11p2v9s2y6830ck040xivb22rwfw02h0phbyg5k4pg6x";
  };

  nativeBuildInputs = [
    cmake
    qt5.wrapQtAppsHook
  ];
  buildInputs = [
    essentia-extractor
    qt5.qtbase
  ];

  postInstall = ''
    ln -s ${essentia-extractor}/bin/streaming_extractor_music $out/bin/streaming_extractor_music
  '';
}
