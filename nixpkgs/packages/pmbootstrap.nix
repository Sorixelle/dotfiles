{ lib, python3Packages, fetchgit }:

python3Packages.buildPythonApplication rec {
  pname = "pmbootstrap";
  version = "1.29.2";

  src = fetchgit {
    url = "https://gitlab.com/postmarketOS/pmbootstrap.git";
    rev = "${version}";
    sha256 = "0in6gxcvrmrmvbw3fr8748kgkmdyhxhlafls4xlz38jdwdk4vjkw";
  };

  doCheck = false;

  meta = with lib; {
    homepage = "https://wiki.postmarketos.org/wiki/Pmbootstrap";
    description =
      "A sophisticated chroot / build / flash tool to develop and install postmarketOS";
    license = licenses.gpl3;
  };
}
