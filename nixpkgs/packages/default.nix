final: prev:

let
  gcc-cortex-a-9 = target:
    prev.callPackage ./gcc-cortex-a.nix { inherit target; };
in {
  alter = prev.callPackage ./ff-exts/alter.nix { };
  frankerfacez = prev.callPackage ./ff-exts/frankerfacez.nix { };
  ff-stylish = prev.callPackage ./ff-exts/stylish.nix { };

  acousticbrainz-gui = prev.callPackage ./acousticbrainz-gui.nix { };

  cifs-utils = prev.cifs-utils.overrideAttrs
    (old: { buildInputs = old.buildInputs ++ [ prev.samba ]; });

  ctrtool = prev.ctrtool.overrideAttrs (_: rec {
    version = "1.2.0";

    src = prev.fetchFromGitHub {
      owner = "3DSGuy";
      repo = "Project_CTR";
      rev = "ctrtool-v${version}";
      hash = "sha256-wjU/DJHrAHE3MSB7vy+swUDVPzw0Jrv4ymOjhfr0BBk=";
    };

    preBuild = ''
      make deps
    '';

    installPhase = ''
      mkdir $out/bin -p
      cp bin/ctrtool${prev.stdenv.hostPlatform.extensions.executable} $out/bin/
    '';
  });

  cutentr = prev.callPackage ./cutentr.nix { };

  gcc-cortex-a-arm = gcc-cortex-a-9 "arm";
  gcc-cortex-a-armhf = gcc-cortex-a-9 "armhf";
  gcc-cortex-a-aarch64 = gcc-cortex-a-9 "aarch64";
  gcc-cortex-a-aarch64-gnu = gcc-cortex-a-9 "aarch64-gnu";
  gcc-cortex-a-aarch64be-gnu = gcc-cortex-a-9 "aarch64be-gnu";

  igir = prev.callPackage ./igir.nix { };

  kstart = prev.callPackage ./kstart.nix { };

  makerom = prev.callPackage ./makerom.nix { };

  mopidy-subidy = prev.callPackage ./mopidy-subidy.nix { };

  # Required to use pipewiresink in mopidy config
  mopidy = prev.mopidy.overrideAttrs
    (old: { buildInputs = old.buildInputs ++ [ final.pipewire ]; });

  moserial = prev.callPackage ./moserial.nix { };

  pmbootstrap = prev.callPackage ./pmbootstrap.nix { };

  powershell = prev.powershell.overrideAttrs (old: rec {
    version = "7.3.4";
    src = prev.fetchzip {
      url =
        "https://github.com/PowerShell/PowerShell/releases/download/v${version}/powershell-${version}-linux-x64.tar.gz";
      hash = "sha256-MohiC9mN74F2HZOsQI0ANO/R6hfIXH2MOMW2/Rce9io=";
      stripRoot = false;
    };
  });

  pywal = prev.callPackage ./pywal { inherit (final) schemer2; };

  schemer2 = prev.callPackage ./schemer2.nix { };

  scr = prev.callPackage ./scr.nix { };
}
