{
  stdenv,
  buildMozillaMach,
  lib,
  fetchurl,
  fetchFromGitHub,

  git,
  nodejs,
  pnpm,
  pkg-config,
  python3,
  vips,
}:

# notes:
# - >= 1.8b has a pnpm-lock.yaml out of sync with package.json, can't build
let
  zenVersion = "1.7.6b";
  firefoxVersion = "135.0";

  firefoxSrc = fetchurl {
    url = "https://archive.mozilla.org/pub/firefox/releases/${firefoxVersion}/source/firefox-${firefoxVersion}.source.tar.xz";
    hash = "sha256-gn4SqWLvR1EQia9EmPZev0L6V8ox23kL/X6agg0WuWA=";
  };

  patchedSrc = stdenv.mkDerivation rec {
    pname = "firefox-zen-browser-src-patched";
    version = "${firefoxVersion}-${zenVersion}";

    src = fetchFromGitHub {
      owner = "zen-browser";
      repo = "desktop";
      rev = zenVersion;
      hash = "sha256-gKma7onLk5XIZARCELVvRUwGXOhwzN1wRDiP3I6mcow=";
      fetchSubmodules = true;
    };
    postUnpack = ''
      tar xf ${firefoxSrc}
      mv firefox-${firefoxVersion} source/engine
    '';

    pnpmDeps = pnpm.fetchDeps {
      inherit pname version src;
      hash = "sha256-+ivPgkcZGAS3mNrYzy91uvgDuQCDTEqKT5mCt9sFWU4=";
    };

    nativeBuildInputs = [
      git
      nodejs
      pnpm.configHook
      pkg-config
      python3
      vips
    ];

    SURFER_MOZCONFIG_ONLY = 1;

    buildPhase = ''
      export npm_config_nodedir=${nodejs}
      (
        cd node_modules/.pnpm/node_modules/sharp
        pnpm run install
      )
      pnpm run import
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
