{ tree-sitter, fetchFromGitHub }:

tree-sitter.buildGrammar rec {
  language = "tree-sitter-astro";
  version = "0.20.8";

  src = fetchFromGitHub {
    owner = "virchau13";
    repo = language;
    rev = "4be180759ec13651f72bacee65fa477c64222a1a";
    hash = "sha256-qc9InFEQgeFfFReJuQd8WjTNK4fFMEaWcqQUcGxxuBI=";
  };
}
