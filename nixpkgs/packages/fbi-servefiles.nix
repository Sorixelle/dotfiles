{ stdenv, python3, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "fbi-servefiles";
  version = "2.6.1";

  src = fetchFromGitHub {
    owner = "Steveice10";
    repo = "FBI";
    rev = "ec259153e25fc77ee999b8caadac7e73d2e5e41a";
    hash = "sha256-KUXAgiCF++JfpwpA3A0/2IGXdyRL2mUMJo4v4kMAJPE=";
  };
  sourceRoot = "source/servefiles";

  buildInputs = [ python3 ];

  installPhase = ''
    install -Dm755 servefiles.py $out/bin/fbi-servefiles
    install -Dm755 sendurls.py $out/bin/fbi-sendurls
  '';
}
