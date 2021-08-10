final: prev:

let
  gcc-cortex-a-9 = target:
    prev.callPackage ./gcc-cortex-a.nix { inherit target; };

  daedalusPkgs = import ("${
      fetchTarball {
        url = "https://github.com/input-output-hk/daedalus/archive/4.0.5.zip";
        sha256 = "1zrg8l08ckylnlrmwr2dnrvph82ry7l4kg3qx80mvwp1ixyg6jfa";
      }
    }/release.nix") { };
in {
  frankerfacez = prev.callPackage ./ff-exts/frankerfacez.nix { };

  acousticbrainz-gui = prev.callPackage ./acousticbrainz-gui.nix { };

  daedalus-mainnet = daedalusPkgs.mainnet.daedalus.x86_64-linux;

  gcc-cortex-a-arm = gcc-cortex-a-9 "arm";
  gcc-cortex-a-armhf = gcc-cortex-a-9 "armhf";
  gcc-cortex-a-aarch64 = gcc-cortex-a-9 "aarch64";
  gcc-cortex-a-aarch64-gnu = gcc-cortex-a-9 "aarch64-gnu";
  gcc-cortex-a-aarch64be-gnu = gcc-cortex-a-9 "aarch64be-gnu";

  mopidy-subidy = prev.callPackage ./mopidy-subidy.nix { };

  moserial = prev.callPackage ./moserial.nix { };

  pmbootstrap = prev.callPackage ./pmbootstrap.nix { };

  pywal = prev.callPackage ./pywal { inherit (final) schemer2; };

  # Fix rofi bug with height calculation
  # https://github.com/davatorium/rofi/issues/1247
  rofi-unwrapped = prev.rofi-unwrapped.overrideAttrs
    (_: { patches = [ ./rofi/rofi-font-height.patch ]; });

  schemer2 = prev.callPackage ./schemer2.nix { };
}
