{
  allowUnfree = true;

  permittedInsecurePackages = [
    "electron-32.3.3"
    "zotero-6.0.27"
  ];

  packageOverrides = pkgs: { nur = import <nur> { inherit pkgs; }; };
}
