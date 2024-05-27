final: prev:

let
  gcc-cortex-a-9 = target:
    prev.callPackage ./gcc-cortex-a.nix { inherit target; };
in {
  alter = prev.callPackage ./ff-exts/alter.nix { };
  frankerfacez = prev.callPackage ./ff-exts/frankerfacez.nix { };
  ff-stylish = prev.callPackage ./ff-exts/stylish.nix { };

  _3dsconv = prev.callPackage ./3dsconv { };

  acousticbrainz-gui = prev.callPackage ./acousticbrainz-gui.nix { };

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

  fbi-servefiles = prev.callPackage ./fbi-servefiles.nix { };

  gcc-cortex-a-arm = gcc-cortex-a-9 "arm";
  gcc-cortex-a-armhf = gcc-cortex-a-9 "armhf";
  gcc-cortex-a-aarch64 = gcc-cortex-a-9 "aarch64";
  gcc-cortex-a-aarch64-gnu = gcc-cortex-a-9 "aarch64-gnu";
  gcc-cortex-a-aarch64be-gnu = gcc-cortex-a-9 "aarch64be-gnu";

  igir = prev.callPackage ./igir.nix { };

  inter-patched = prev.callPackage ./inter-patched.nix { };

  kstart = prev.callPackage ./kstart.nix { };

  makerom = prev.callPackage ./makerom.nix { };

  moserial = prev.callPackage ./moserial.nix { };

  pmbootstrap = prev.callPackage ./pmbootstrap.nix { };

  pywal = prev.callPackage ./pywal { inherit (final) schemer2; };

  pyftfeatfreeze = prev.callPackage ./pyftfeatfreeze.nix { };

  rescrobbled = prev.callPackage ./rescrobbled.nix { };

  schemer2 = prev.callPackage ./schemer2.nix { };

  scr = prev.callPackage ./scr.nix { };

  tree-sitter = prev.tree-sitter.override {
    extraGrammars = {
      tree-sitter-astro = prev.callPackage ./tree-sitter-astro.nix { };
    };
  };

  wineasio = prev.wineasio.overrideAttrs (old: {
    nativeBuildInputs = [ prev.pkg-config prev.wineWowPackages.staging ];
    makeFlags = [ "PREFIX=${prev.wineWowPackages.staging}" ];
  });
}
