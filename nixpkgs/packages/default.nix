final: prev:

{
  _3dsconv = prev.callPackage ./3dsconv { };

  cutentr = prev.callPackage ./cutentr.nix { };

  fbi-servefiles = prev.callPackage ./fbi-servefiles.nix { };

  frankerfacez = prev.callPackage ./frankerfacez.nix { };

  git-diffie = prev.callPackage (prev.fetchFromGitHub {
    owner = "the6p4c";
    repo = "git-diffie";
    rev = "7a3f46d8615ace71467e31827e30da44856c44e1";
    hash = "sha256-JgQXIUYqO1wPBYxWfyb4ZAxjqX9ykt98grd5SHqEKD8=";
  }) { };

  inter-patched = prev.callPackage ./inter-patched.nix { };

  makerom = prev.callPackage ./makerom.nix { };

  pyftfeatfreeze = prev.callPackage ./pyftfeatfreeze.nix { };

  rescrobbled = prev.callPackage ./rescrobbled.nix { };

  scr = prev.callPackage ./scr.nix { };

  tinfoil-nut = prev.callPackage ./tinfoil-nut.nix { };

  xsane = prev.xsane.override { gimpSupport = true; };
}
