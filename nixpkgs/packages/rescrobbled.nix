{
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  dbus,
  openssl,
}:

rustPlatform.buildRustPackage rec {
  pname = "rescrobbled";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "InputUsername";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-1E+SeKjHCah+IFn2QLAyyv7jgEcZ1gtkh8iHgiVBuz4=";
  };

  postPatch = ''
    substituteInPlace src/filter.rs --replace "/usr/bin/bash" "/bin/sh"
  '';

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    dbus
    openssl
  ];

  cargoHash = "sha256-ZJbyYFvGTuXt1aqhGOATcDRrkTk7SorWXkN81sUoDdo=";
}
