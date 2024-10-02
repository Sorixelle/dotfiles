{ lib, nur }:

nur.repos.rycee.firefox-addons.buildFirefoxXpiAddon {
  pname = "stylish";
  version = "3.1.8";
  addonId = "{46551EC9-40F0-4e47-8E18-8E5CF550CFB8}";
  url = "https://addons.mozilla.org/firefox/downloads/file/1025565/stylish-3.1.8.xpi";
  sha256 = "VNzbRp60Qq7m+gNIwJIlHRx/xOu0TsNPf0FZC8yATpo=";
  meta = with lib; {
    description = "Redirect to privacy-friendly alternatives";
    license = licenses.gpl3;
    platforms = platforms.all;
  };
}
