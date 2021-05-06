{ lib, python39Packages, imagemagick, feh, schemer2 }:

let
  colorthief = python39Packages.buildPythonPackage rec {
    pname = "colorthief";
    version = "0.2.1";
    propagatedBuildInputs = with python39Packages; [ pillow ];
    src = python39Packages.fetchPypi {
      inherit pname version;
      sha256 = "08bjsmmkihyksms2vgndslln02rvw56lkxz28d39qrnxbg4v1707";
    };
  };
  colorz = python39Packages.buildPythonPackage rec {
    pname = "colorz";
    version = "1.0.3";
    propagatedBuildInputs = with python39Packages; [ pillow scipy ];
    src = python39Packages.fetchPypi {
      inherit pname version;
      sha256 = "0ghd90lgplf051fs5n5bb42zffd3fqpgzkbv6bhjw7r8jqwgcky0";
    };
  };
  haishoku = python39Packages.buildPythonPackage rec {
    pname = "haishoku";
    version = "1.1.8";
    propagatedBuildInputs = with python39Packages; [ pillow ];
    src = python39Packages.fetchPypi {
      inherit pname version;
      sha256 = "1m6bzxlm4pfdpjr827k1zy9ym3qn411lpw5wiaqq2q2q0d6a3fg4";
    };
  };
in python39Packages.buildPythonPackage rec {
  pname = "pywal";
  version = "3.3.0";

  src = python39Packages.fetchPypi {
    inherit pname version;
    sha256 = "1drha9kshidw908k7h3gd9ws2bl64ms7bjcsa83pwb3hqa9bkspg";
  };

  propagatedBuildInputs = [ colorthief colorz haishoku schemer2 ];

  preCheck = ''
    mkdir tmp
    HOME=$PWD/tmp
  '';

  patches = [
    ./convert.patch
    ./feh.patch
  ];

  postPatch = ''
    substituteInPlace pywal/backends/wal.py --subst-var-by convert "${imagemagick}/bin/convert"
    substituteInPlace pywal/wallpaper.py --subst-var-by feh "${feh}/bin/feh"
  '';

  meta = with lib; {
    description = "Generate and change colorschemes on the fly. A 'wal' rewrite in Python 3";
    homepage = "https://github.com/dylanaraps/pywal";
    license = licenses.mit;
    maintainers = with maintainers; [ Fresheyeball ];
  };
}
