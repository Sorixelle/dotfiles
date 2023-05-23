{ stdenv, fetchFromGitLab, qt5 }:

stdenv.mkDerivation rec {
  pname = "cutentr";
  version = "0.3.3";

  src = fetchFromGitLab {
    owner = "BoltsJ";
    repo = pname;
    rev = version;
    hash = "sha256-KfnC9R38qSMhQDeaMBWm1HoO3Wzs5kyfPFwdMZCWw4E=";
  };

  buildInputs = [ qt5.qtbase ];
  nativeBuildInputs = [ qt5.wrapQtAppsHook ];

  postPatch = ''
    substituteInPlace cutentr.pro --replace /usr/local $out
    substituteInPlace src/src.pro --replace /usr/local $out
  '';

  configurePhase = "qmake";
}
