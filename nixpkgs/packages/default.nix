final: prev:

{
  _3dsconv = prev.callPackage ./3dsconv { };

  cutentr = prev.callPackage ./cutentr.nix { };

  fbi-servefiles = prev.callPackage ./fbi-servefiles.nix { };

  frankerfacez = prev.callPackage ./frankerfacez.nix { };

  inter-patched = prev.callPackage ./inter-patched.nix { };

  makerom = prev.callPackage ./makerom.nix { };

  pyftfeatfreeze = prev.callPackage ./pyftfeatfreeze.nix { };

  rebuild = prev.callPackage ./rebuild { };

  rescrobbled = prev.callPackage ./rescrobbled.nix { };

  roon-launcher = prev.callPackage ./roon { };

  scr = prev.callPackage ./scr.nix { };

  tinfoil-nut = prev.callPackage ./tinfoil-nut.nix { };

  vlc = prev.vlc.override {
    libbluray = prev.libbluray.override {
      withAACS = true;
      withBDplus = true;
    };
  };

  yubikey-touch-alert = prev.callPackage ./yubikey-touch-alert.nix { };

  zen-browser-unwrapped = prev.callPackage ./zen-browser.nix { };
  zen-browser = prev.wrapFirefox final.zen-browser-unwrapped {
    pname = "zen-browser";
  };
}
