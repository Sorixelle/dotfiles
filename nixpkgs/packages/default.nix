pins: final: prev:

{
  _3dsconv = prev.callPackage ./3dsconv { };

  cutentr = prev.callPackage ./cutentr.nix { };

  fbi-servefiles = prev.callPackage ./fbi-servefiles.nix { };

  frankerfacez = prev.callPackage ./frankerfacez.nix { };

  go-grip = prev.callPackage ./go-grip.nix { };

  # Version 2.0.0-rc1, not in nixpkgs
  hyfetch = prev.callPackage ./hyfetch.nix { };

  inter-patched = prev.callPackage ./inter-patched.nix { };

  makerom = prev.callPackage ./makerom.nix { };

  # NUR doesn't expose an overlay by default, but it's trivial to add it to one
  nur = import pins.nur { pkgs = final; };

  pyftfeatfreeze = prev.callPackage ./pyftfeatfreeze.nix { };

  rebuild = prev.callPackage ./rebuild { };

  rescrobbled = prev.callPackage ./rescrobbled.nix { };

  roon-launcher = prev.callPackage ./roon { };

  scr = prev.callPackage ./scr.nix { };

  senpai-desktop = prev.callPackage ./senpai-desktop.nix { };

  tinfoil-nut = prev.callPackage ./tinfoil-nut.nix { };

  # tree-sitter-astro doesn't provide an overlay outside of the flake, so we'll reconstruct it here
  tree-sitter = prev.tree-sitter.override {
    extraGrammars.tree-sitter-astro = prev.tree-sitter.buildGrammar {
      language = "astro";
      version = builtins.substring 0 7 pins.tree-sitter-astro.revision;
      src = pins.tree-sitter-astro.outPath;
    };
  };

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
