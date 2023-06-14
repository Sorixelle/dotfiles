{ tree-sitter, fetchFromGitHub }:

tree-sitter.buildGrammar rec {
  language = "tree-sitter-astro";
  version = "0.20.8";

  src = fetchFromGitHub {
    owner = "virchau13";
    repo = language;
    rev = "a4535d1530558866a543c1660c90c57fbf2fd709";
    hash = "sha256-ZWpxKAyja6bW2kNxalHOL2E+WFbEKc40dMGrB1Ihs6I=";
  };
}
