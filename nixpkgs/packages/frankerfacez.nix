{ lib, nur }:

nur.repos.rycee.firefox-addons.buildFirefoxXpiAddon {
  pname = "frankerfacez";
  version = "4.0";
  addonId = "frankerfacez@frankerfacez.com";
  url = "https://cdn.frankerfacez.com/script/frankerfacez-4.0-an+fx.xpi";
  sha256 = "0kx0dax1cv4h7hkbisw96sh2qxpmfgq1sbd49531kycwmnnq1z2k";
  meta = with lib; {
    homepage = "https://www.frankerfacez.com/";
    description = "The Twitch Enhancement Suite";
    license = licenses.unfree;
    platforms = platforms.all;
  };
}
