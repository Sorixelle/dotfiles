{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "makerom";
  version = "0.18.3";

  src = fetchFromGitHub {
    owner = "3DSGuy";
    repo = "Project_CTR";
    rev = "makerom-v${version}";
    hash = "sha256-Ya4GjlBBthzHptZhT9wjZMdjkUctaWsRhRwC57c4XCE=";
  };

  sourceRoot = "source/makerom";

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "CXX=${stdenv.cc.targetPrefix}c++"
  ];
  enableParallelBuilding = true;

  preBuild = ''
    make deps
  '';

  installPhase = ''
    mkdir $out/bin -p
    cp bin/makerom${stdenv.hostPlatform.extensions.executable} $out/bin/
  '';

  meta = with lib; {
    license = licenses.mit;
    description = "A tool for creating 3DS cxi/cfa/cci/cia files";
    platforms = platforms.linux;
  };

}
