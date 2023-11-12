{
  allowUnfree = true;

  permittedInsecurePackages = [ "zotero-6.0.27" ];

  packageOverrides = pkgs: { nur = import <nur> { inherit pkgs; }; };
}
