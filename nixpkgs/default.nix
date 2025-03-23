let
  sources = import ../npins;
in

# Construct a nixpkgs set, from version pinned in npins
import sources.nixpkgs {
  # Use common nixpkgs configuration
  config = import ./config.nix;

  overlays = [
    (import sources.emacs-overlay)
    (import "${sources.git-diffie}/overlay.nix")
    (final: prev: {
      # NUR doesn't expose an overlay by default, but it's trivial to add it to one
      nur = import sources.nur { pkgs = final; };

      # tree-sitter-astro doesn't provide an overlay outside of the flake, so we'll reconstruct it here
      tree-sitter = prev.tree-sitter.override {
        extraGrammars.tree-sitter-astro = prev.tree-sitter.buildGrammar {
          language = "astro";
          version = builtins.substring 0 7 sources.tree-sitter-astro.revision;
          src = sources.tree-sitter-astro.outPath;
        };
      };
    })

    # Also include all of our custom definitions
    (import ./packages)
  ];
}
