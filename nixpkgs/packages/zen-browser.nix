{
  buildMozillaMach,
  buildNpmPackage,
  lib,
  fetchurl,
  fetchFromGitHub,

  git,
  pkg-config,
  python3,
  vips,
}:

let
  zenVersion = "1.10.3b";
  firefoxVersion = "136.0.4";

  firefoxSrc = fetchurl {
    url = "https://archive.mozilla.org/pub/firefox/releases/${firefoxVersion}/source/firefox-${firefoxVersion}.source.tar.xz";
    hash = "sha256-Sii54cK48vHUNHReu4f8uorhFqICh48Pseg9pjz3wkI=";
  };

  patchedSrc = buildNpmPackage {
    pname = "firefox-zen-browser-src-patched";
    version = "${firefoxVersion}-${zenVersion}";

    src = fetchFromGitHub {
      owner = "zen-browser";
      repo = "desktop";
      rev = zenVersion;
      hash = "sha256-dEP2F/G+24Y7KI84roZdXGwklhTCXr2oulribl1y+Jo=";
      fetchSubmodules = true;
    };
    postUnpack = ''
      tar xf ${firefoxSrc}
      mv firefox-${firefoxVersion} source/engine
    '';

    npmDepsHash = "sha256-qIXoI/8mXpLYUa6H7mF4UN42FmKl9GPWsb1vO0Wcitg=";
    makeCacheWritable = true;

    nativeBuildInputs = [
      git
      pkg-config
      python3
    ];
    # TODO: this should be in nativeBuildInputs, since sharp is only used during build, but it doesn't seem to be
    # visible in there. why not?
    buildInputs = [
      vips
    ];

    buildPhase = ''
      npm run import
      python ./scripts/update_en_US_packs.py
    '';

    installPhase = ''
      cp -r engine $out

      cd $out
      for i in $(find . -type l); do
        realpath=$(readlink $i)
        rm $i
        cp $realpath $i
      done
    '';

    dontFixup = true;
  };
in
(buildMozillaMach {
  pname = "zen-browser";
  packageVersion = zenVersion;
  version = firefoxVersion;
  applicationName = "Zen Browser";
  binaryName = "zen";
  branding = "browser/branding/release";
  requireSigning = false;
  allowAddonSideload = true;

  src = patchedSrc;

  extraConfigureFlags = [
    "--with-app-basename=Zen"
  ];

  meta = {
    description = "Privacy-focused browser that blocks trackers, ads, and other unwanted content while offering the best browsing experience";
    homepage = "https://zen-browser.app/";
    downloadPage = "https://zen-browser.app/download/";
    changelog = "https://zen-browser.app/release-notes/#${zenVersion}";
    license = lib.licenses.mpl20;
    platforms = lib.platforms.unix;
    mainProgram = "zen";
  };
}).override
  {
    pgoSupport = false;
    crashreporterSupport = false;
    enableOfficialBranding = false;
  }
