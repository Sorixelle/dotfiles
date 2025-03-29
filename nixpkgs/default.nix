let
  sources = import ../npins;
in

# Construct a nixpkgs set, from version pinned in npins
import sources.nixpkgs {
  # Use common nixpkgs configuration
  config = import ./config.nix;

  # And common overlays
  overlays = import ./overlays.nix;
}
