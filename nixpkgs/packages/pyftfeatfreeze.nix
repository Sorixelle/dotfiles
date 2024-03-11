{ python3Packages, fetchFromGitHub }:

python3Packages.buildPythonApplication {
  pname = "pyftfeatfreeze";
  version = "1.32.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "twardoch";
    repo = "fonttools-opentype-feature-freezer";
    rev = "2ae16853bc724c3e377726f81d9fc661d3445827";
    hash = "sha256-mIWQF9LTVKxIkwHLCTVK1cOuiaduJyX8pyBZ/0RKIVE=";
  };

  nativeBuildInputs = with python3Packages; [ poetry-core configparser ];

  propagatedBuildInputs = with python3Packages; [ fonttools ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace "poetry.masonry.api" "poetry.core.masonry.api" \
      --replace "poetry>=" "poetry-core>="
  '';
}
