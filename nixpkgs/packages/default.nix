final: prev:

let
  gcc-cortex-a-9 = target:
    prev.callPackage ./gcc-cortex-a.nix { inherit target; };
in {
  frankerfacez = prev.callPackage ./ff-exts/frankerfacez.nix { };

  acousticbrainz-gui = prev.callPackage ./acousticbrainz-gui.nix { };

  gcc-cortex-a-arm = gcc-cortex-a-9 "arm";
  gcc-cortex-a-armhf = gcc-cortex-a-9 "armhf";
  gcc-cortex-a-aarch64 = gcc-cortex-a-9 "aarch64";
  gcc-cortex-a-aarch64-gnu = gcc-cortex-a-9 "aarch64-gnu";
  gcc-cortex-a-aarch64be-gnu = gcc-cortex-a-9 "aarch64be-gnu";

  mopidy-subidy = prev.callPackage ./mopidy-subidy.nix { };

  moserial = prev.callPackage ./moserial.nix { };

  pmbootstrap = prev.callPackage ./pmbootstrap.nix { };

  pywal = prev.callPackage ./pywal { inherit (final) schemer2; };

  schemer2 = prev.callPackage ./schemer2.nix { };
}
