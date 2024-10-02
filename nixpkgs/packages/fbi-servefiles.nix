{
  stdenv,
  python3,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "fbi-servefiles";
  version = "2.6.1";

  src = fetchFromGitHub {
    owner = "nh-server";
    repo = "FBI-NH";
    rev = "a65971aec5c6e9b78daf955c53324de98f500fce";
    hash = "sha256-c9sz06zv35kgJ+k+XaWV7KMe+nJOzro1iV52Pud1xXE=";
  };
  sourceRoot = "source/servefiles";

  buildInputs = [ python3 ];

  installPhase = ''
    install -Dm755 servefiles.py $out/bin/fbi-servefiles
    install -Dm755 sendurls.py $out/bin/fbi-sendurls
  '';
}
