self: super:

let
  gcc-cortex-a-9 = target:
    super.callPackage ./gcc-cortex-a.nix { inherit target; };

  daedalusPkgs = import ("${
      fetchTarball {
        url = "https://github.com/input-output-hk/daedalus/archive/4.0.5.zip";
        sha256 = "1zrg8l08ckylnlrmwr2dnrvph82ry7l4kg3qx80mvwp1ixyg6jfa";
      }
    }/release.nix") { };
in {
  frankerfacez = super.callPackage ./ff-exts/frankerfacez.nix { };

  acousticbrainz-gui = super.callPackage ./acousticbrainz-gui.nix { };

  daedalus-mainnet = daedalusPkgs.mainnet.daedalus.x86_64-linux;

  gcc-cortex-a-arm = gcc-cortex-a-9 "arm";
  gcc-cortex-a-armhf = gcc-cortex-a-9 "armhf";
  gcc-cortex-a-aarch64 = gcc-cortex-a-9 "aarch64";
  gcc-cortex-a-aarch64-gnu = gcc-cortex-a-9 "aarch64-gnu";
  gcc-cortex-a-aarch64be-gnu = gcc-cortex-a-9 "aarch64be-gnu";

  mopidy-subidy = super.callPackage ./mopidy-subidy.nix { };

  moserial = super.callPackage ./moserial.nix { };

  pmbootstrap = super.callPackage ./pmbootstrap.nix { };

  pywal = super.callPackage ./pywal { };

  # Fix rofi bug with height calculation
  # https://github.com/davatorium/rofi/issues/1247
  rofi-unwrapped = super.rofi-unwrapped.overrideAttrs
    (_: { patches = [ ./rofi/rofi-font-height.patch ]; });

  schemer2 = super.callPackage ./schemer2.nix { };
}
