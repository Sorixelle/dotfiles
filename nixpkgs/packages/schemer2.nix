{ stdenv, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  pname = "schemer2";
  version = "2019-04-06";
  rev = "89a66cbf40440e82921719c6919f11bb563d7cfa";

  goPackagePath = "github.com/thefryscorer/schemer2";

  src = fetchFromGitHub {
    inherit rev;
    owner = "thefryscorer";
    repo = "schemer2";
    sha256 = "0z1nv9gdswfci6y180slvyx4ba2ifc4ifb1b39mdrik4hg7xba0h";
  };
}
