{ buildNpmPackage, fetchFromGitHub }:

buildNpmPackage rec {
  pname = "igir";
  version = "1.6.2";

  src = fetchFromGitHub {
    owner = "emmercm";
    repo = "igir";
    rev = "8edcd67bbe7a872a2dc4084c1301d57bac454afc";
    hash = "sha256-2gqfPsBwsT7K9+DebS49KgF3HklP2ELEvGlxcOwoPis=";
  };

  npmDepsHash = "sha256-ww8Os20X1pHE8ltxQlvwAZYwIw18Tukufq12WzWt45w=";

  npmPackFlags = [ "--ignore-scripts" ];
}
