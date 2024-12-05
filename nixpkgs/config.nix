{
  allowUnfree = true;

  permittedInsecurePackages = [
    "cinny-4.2.3"
    "cinny-unwrapped-4.2.3"
    "olm-3.2.16"
    "zotero-6.0.27"
  ];

  packageOverrides = pkgs: { nur = import <nur> { inherit pkgs; }; };
}
