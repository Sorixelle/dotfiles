{
  lib,
  rustPlatform,
  fetchFromGitHub,
  makeWrapper,
  installShellFiles,

  pciutils,
  withFastfetch ? true,
  fastfetch,
  withMacchina ? true,
  macchina,
}:

rustPlatform.buildRustPackage rec {
  pname = "hyfetch";
  version = "2.0.0-rc1";

  src = fetchFromGitHub {
    owner = "hykilpikonna";
    repo = "hyfetch";
    rev = version;
    hash = "sha256-ocIrTMBxiJ80sGfPl2mHpqV2LCGwKLZ08AAT2uJNM0I=";
  };

  buildInputs =
    [ pciutils ] ++ (lib.optional withFastfetch fastfetch) ++ (lib.optional withMacchina macchina);
  nativeBuildInputs = [
    makeWrapper
    installShellFiles
  ];

  useFetchCargoVendor = true;
  cargoHash = "sha256-ERlRi7CGa1xGbAugl2Nm7a1VCPd2vVyaW65lcpvnQUs=";

  postInstall = ''
    cp -L hyfetch/scripts/neowofetch $out/bin/neowofetch
    installShellCompletion --cmd neowofetch hyfetch/scripts/autocomplete.{bash,zsh}
  '';

  postFixup = ''
    wrapProgram $out/bin/hyfetch \
      --prefix PATH : ${
        lib.makeBinPath ((lib.optional withFastfetch fastfetch) ++ (lib.optional withMacchina macchina))
      }
    wrapProgram $out/bin/neowofetch \
      --prefix PATH : ${lib.makeBinPath [ pciutils ]}
  '';
}
