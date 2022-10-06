{ stdenv, fetchurl, gtk3, intltool, itstool, libxml2, pkg-config, wrapGAppsHook
}:

stdenv.mkDerivation rec {
  pname = "moserial";
  version = "3.0.16";

  src = fetchurl {
    url =
      "https://download.gnome.org/sources/moserial/3.0/moserial-${version}.tar.xz";
    sha256 = "0x3dbvhxpqc4i4jaky698658clf7b5z3nh9b79xy7a8c4j76srqy";
  };

  nativeBuildInputs = [ intltool itstool pkg-config wrapGAppsHook ];
  buildInputs = [ gtk3 libxml2 ];
}
