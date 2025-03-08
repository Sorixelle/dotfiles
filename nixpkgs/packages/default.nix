final: prev:

{
  _3dsconv = prev.callPackage ./3dsconv { };

  cutentr = prev.callPackage ./cutentr.nix { };

  fbi-servefiles = prev.callPackage ./fbi-servefiles.nix { };

  frankerfacez = prev.callPackage ./frankerfacez.nix { };

  inter-patched = prev.callPackage ./inter-patched.nix { };

  makerom = prev.callPackage ./makerom.nix { };

  pyftfeatfreeze = prev.callPackage ./pyftfeatfreeze.nix { };

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

  # TODO: remove when merged
  # https://github.com/NixOS/nixpkgs/pull/370637
  xsane = (prev.xsane.override { gimpSupport = true; }).overrideAttrs (_: {
    patches =
      let
        fetchFedoraPatch =
          { name, hash }:
          prev.fetchpatch {
            inherit name hash;
            url = "https://src.fedoraproject.org/rpms/xsane/raw/846ace0a29063335c708b01e9696eda062d7459c/f/${name}";
          };
      in
      map fetchFedoraPatch [
        {
          name = "0001-Follow-new-convention-for-registering-gimp-plugin.patch";
          hash = "sha256-yOY7URyc8HEHHynvdcZAV1Pri31N/rJ0ddPavOF5zLw=";
        }
        {
          name = "xsane-0.995-close-fds.patch";
          hash = "sha256-qE7larHpBEikz6OaOQmmi9jl6iQxy/QM7iDg9QrVV1o=";
        }
        {
          name = "xsane-0.995-xdg-open.patch";
          hash = "sha256-/kHwwuDC2naGEp4NALfaJ0pJe+9kYhV4TX1eGeARvq8=";
        }
        {
          name = "xsane-0.996-no-eula.patch";
          hash = "sha256-CYmp1zFg11PUPz9um2W7XF6pzCzafKSEn2nvPiUSxNo=";
        }
        {
          name = "xsane-0.997-ipv6.patch";
          hash = "sha256-D3xH++DHxyTKMxgatU+PNCVN1u5ajPc3gQxvzhMYIdM=";
        }
        {
          name = "xsane-0.997-off-root-build.patch";
          hash = "sha256-2LXQfMbvqP+TAhAmxRe6pBqNlSX4tVjhDkBHIfX9HcA=";
        }
        {
          name = "xsane-0.998-desktop-file.patch";
          hash = "sha256-3xEj6IaOk/FS8pv+/yaNjZpIoB+0Oei0QB9mD4/owkM=";
        }
        {
          name = "xsane-0.998-libpng.patch";
          hash = "sha256-0z292+Waa2g0PCQpUebdWprl9VDyBOY0XgqMJaIcRb8=";
        }
        {
          name = "xsane-0.998-preview-selection.patch";
          hash = "sha256-TZ8vRA+0qPY2Rqz0VNHjgkj3YPob/BW+zBoVqxnUhb8=";
        }
        {
          name = "xsane-0.998-wmclass.patch";
          hash = "sha256-RubFOs+hsZS+GdxF0yvLSy4v+Fi6vb9G6zfwWZcUlkY=";
        }
        {
          name = "xsane-0.999-lcms2.patch";
          hash = "sha256-eiAxa1lhFrinqBvlIhH+NP7WBKk0Plf2S+OVTcpxXac=";
        }
        {
          name = "xsane-0.999-man-page.patch";
          hash = "sha256-4g0w4x9boAIOA6s5eTzKMh2mkkRKtF1TZ9KgHNTDaAg=";
        }
        {
          name = "xsane-0.999-no-file-selected.patch";
          hash = "sha256-e/QKtvsIwU5yy0SJKAEAmhmCoxWqV6FHmAW41SbW/eI=";
        }
        {
          name = "xsane-0.999-pdf-no-high-bpp.patch";
          hash = "sha256-o3LmOvgERuB9CQ8RL2Nd40h1ePuuuGMSK1GN68QlJ6s=";
        }
        {
          name = "xsane-0.999-signal-handling.patch";
          hash = "sha256-JU9BJ6UIDa1FsuPaQKsxcjxvsJkwgmuopIqCVWY3LQ0=";
        }
        {
          name = "xsane-0.999-snprintf-update.patch";
          hash = "sha256-bSTeoIOLeJ4PEsBHR+ZUQLPmrc0D6aQzyJGlLVhXt8o=";
        }
        {
          name = "xsane-configure-c99.patch";
          hash = "sha256-ukaNGgzCGiQwbOzSguAqBIKOUzXofSC3lct812U/8gY=";
        }
      ];
  });
  yubikey-touch-alert = prev.callPackage ./yubikey-touch-alert.nix { };

  zen-browser-unwrapped = prev.callPackage ./zen-browser.nix { };
  zen-browser = prev.wrapFirefox final.zen-browser-unwrapped {
    pname = "zen-browser";
  };
}
