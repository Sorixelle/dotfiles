let
  sources = import ../npins;

  pkgs = import sources.nixpkgs {
    config = import ../nixpkgs/config.nix;
    overlays = [
      (import sources.emacs-overlay)
      (import "${sources.git-diffie}/overlay.nix")
      (final: prev: {
        nur = import sources.nur {
          inherit pkgs;
        };
        tree-sitter = prev.tree-sitter.override {
          extraGrammars.tree-sitter-astro = prev.tree-sitter.buildGrammar {
            language = "astro";
            version = builtins.substring 0 7 sources.tree-sitter-astro.revision;
            src = sources.tree-sitter-astro.outPath;
          };
        };
      })
      (import ../nixpkgs/packages)
    ];
  };
in
{ ... }:

{
  imports = [
    (import "${sources.home-manager}/nixos")
    (import "${sources.lix-module}/module.nix" (
      let
        lix = import sources.lix;
        lixRev = builtins.substring 0 7 sources.lix.revision;
      in
      {
        inherit lix;
        versionSuffix = "-${lixRev}";
      }
    ))

    ../system/common.nix
    ../system/sapphire.nix
  ];

  networking.hostName = "sapphire";

  nixpkgs.pkgs = pkgs;
}
