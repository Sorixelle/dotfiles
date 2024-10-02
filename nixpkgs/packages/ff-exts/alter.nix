{ lib, nur }:

nur.repos.rycee.firefox-addons.buildFirefoxXpiAddon {
  pname = "alter";
  version = "7.0";
  addonId = "{5d6e7c48-0f9b-401d-896d-37fd423809d3}";
  url = "https://addons.mozilla.org/firefox/downloads/file/3974840/alter-7.0.xpi";
  sha256 = "cdc2f04304548b20df78153d0b83d1b976221e6aa5c1446b0ebaedb37e71513b";
  meta = with lib; {
    description = "Redirect to privacy-friendly alternatives";
    license = licenses.gpl3;
    platforms = platforms.all;
  };
}
