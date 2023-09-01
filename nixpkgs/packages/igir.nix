{ buildNpmPackage, fetchFromGitHub }:

buildNpmPackage {
  pname = "igir";
  version = "1.9.3";

  src = fetchFromGitHub {
    owner = "emmercm";
    repo = "igir";
    rev = "4239e0be22648cd12b0f93253d93fc16781f20a1";
    hash = "sha256-Zgea9nLwJD1U1LMa7rrR5Y0liVWc6BxSSlaiPn1GfIM=";
  };

  npmDepsHash = "sha256-Xv9iwHzKUGHaFcCjGBUoBWe33M6hetdGFD46X9vR8ts=";

  npmPackFlags = [ "--ignore-scripts" ];
}
