final: prev:

let
  affinityPackages = prev.callPackage ./affinity { };

  gcc-cortex-a-9 = target: prev.callPackage ./gcc-cortex-a.nix { inherit target; };
in
{
  alter = prev.callPackage ./ff-exts/alter.nix { };
  frankerfacez = prev.callPackage ./ff-exts/frankerfacez.nix { };
  ff-stylish = prev.callPackage ./ff-exts/stylish.nix { };

  _3dsconv = prev.callPackage ./3dsconv { };

  acousticbrainz-gui = prev.callPackage ./acousticbrainz-gui.nix { };

  inherit (affinityPackages) affinity-designer affinity-photo;

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

  git-diffie = prev.callPackage (prev.fetchFromGitHub {
    owner = "the6p4c";
    repo = "git-diffie";
    rev = "7a3f46d8615ace71467e31827e30da44856c44e1";
    hash = "sha256-JgQXIUYqO1wPBYxWfyb4ZAxjqX9ykt98grd5SHqEKD8=";
  }) { };

  igir = prev.callPackage ./igir.nix { };

  inter-patched = prev.callPackage ./inter-patched.nix { };

  kstart = prev.callPackage ./kstart.nix { };

  liquidctl = prev.liquidctl.overrideAttrs (_: {
    src = prev.fetchFromGitHub {
      owner = "liquidctl";
      repo = "liquidctl";
      rev = "256311b99053cba69fe9d5d6fe86e9ebb1849206";
      hash = "sha256-vwNjOVPrHsUxjxPOzQ3Wbxt293bmCPfiqgX5RkLupXM=";
    };
    patches = [ ];
  });

  makerom = prev.callPackage ./makerom.nix { };

  moserial = prev.callPackage ./moserial.nix { };

  pmbootstrap = prev.callPackage ./pmbootstrap.nix { };

  pywal = prev.callPackage ./pywal { inherit (final) schemer2; };

  pyftfeatfreeze = prev.callPackage ./pyftfeatfreeze.nix { };

  rescrobbled = prev.callPackage ./rescrobbled.nix { };

  schemer2 = prev.callPackage ./schemer2.nix { };

  scr = prev.callPackage ./scr.nix { };

  tinfoil-nut = prev.callPackage ./tinfoil-nut.nix { };

  tree-sitter = prev.tree-sitter.override {
    extraGrammars = {
      tree-sitter-astro = prev.callPackage ./tree-sitter-astro.nix { };
    };
  };

  # TODO: why broke
  # /bin/ld: cannot find -lodbc32: No such file or directory
  # wineasio = prev.wineasio.overrideAttrs (old: {
  #   nativeBuildInputs = [ prev.pkg-config prev.wineWowPackages.staging ];
  #   makeFlags = [ "PREFIX=${prev.wineWowPackages.staging}" ];
  # });

  xsane = prev.xsane.override { gimpSupport = true; };
}
