{ python3Packages, fetchFromGitHub }:

python3Packages.buildPythonPackage rec {
  pname = "3dsconv";
  version = "4.2";

  src = fetchFromGitHub {
    owner = "ihaveamac";
    repo = pname;
    rev = "bde8c8f1b70531b539e3cdb7595f6b21a0d43085";
    hash = "sha256-PeyDv9RJ5dPMFsdWwvzw7RU7qdhmjFNSlXklmZNpZAo=";
  };

  patches = [ ./fix-python-import.patch ];

  propagatedBuildInputs = [ python3Packages.pyaes ];

  doCheck = false;
}
