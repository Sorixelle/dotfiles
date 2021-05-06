{ fetchFromGitHub, python3Packages, mopidy }:

python3Packages.buildPythonApplication {
  pname = "mopidy-subidy";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "Prior99";
    repo = "mopidy-subidy";
    rev = "e8493923c1c15db1424d41444aa799c81a337e57";
    sha256 = "08k4vfl4n58pxf09x1yi2nrr6i67khymkx110p8r58jj5vv6yqkd";
  };

  propagatedBuildInputs = with python3Packages; [
    mopidy
    py-sonic
  ];
}
