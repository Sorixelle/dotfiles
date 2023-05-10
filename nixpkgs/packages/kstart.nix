{ stdenv, fetchFromGitHub, autoreconfHook, pkg-config, perl, krb5 }:

stdenv.mkDerivation rec {
  pname = "kstart";
  version = "4.3";

  src = fetchFromGitHub {
    owner = "rra";
    repo = pname;
    rev = "967a8157a41627218b01053ae87b06fda1ce07cb";
    hash = "sha256-MGWL4oNc0MZTGWqBEt2wRTkqoagiUTDrS0kz4ewbZZA=";
  };

  buildInputs = [ krb5 ];
  nativeBuildInputs = [ autoreconfHook pkg-config perl ];

  preConfigure = ''
    pod2man --release="$version" --center="kstart" docs/k5start.pod > docs/k5start.1
    pod2man --release="$version" --center="kstart" docs/krenew.pod > docs/krenew.1
  '';
}
