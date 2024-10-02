{
  stdenv,
  inter,
  pyftfeatfreeze,
  python3Packages,
}:

stdenv.mkDerivation {
  pname = "inter-patched";
  inherit (inter) version;

  src = inter;

  nativeBuildInputs = [
    pyftfeatfreeze
    python3Packages.fonttools
  ];

  buildPhase = ''
    cd /build

    for i in $(seq 0 35); do
      fonttools ttLib -o Inter-$i.ttf -y $i $src/share/fonts/truetype/Inter.ttc
      pyftfeatfreeze -f 'ss01,ss02' -R 'Inter/Intur' Inter-$i.ttf Intur-$i.ttf
    done

    fonttools ttLib -o Intur.ttc Intur-*.ttf
    pyftfeatfreeze -f 'ss01,ss02' -R 'Inter/Intur' $src/share/fonts/truetype/InterVariable.ttf InturVariable.ttf
    pyftfeatfreeze -f 'ss01,ss02' -R 'Inter/Intur' $src/share/fonts/truetype/InterVariable-Italic.ttf InturVariable-Italic.ttf
  '';

  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    cp Intur.ttc InturVariable.ttf InturVariable-Italic.ttf $out/share/fonts/truetype
  '';
}
