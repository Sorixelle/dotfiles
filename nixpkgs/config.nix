{
  allowUnfree = true;

  permittedInsecurePackages =
    [ "cinny-4.1.0" "cinny-unwrapped-4.1.0" "olm-3.2.16" "zotero-6.0.27" ];

  packageOverrides = pkgs: { nur = import <nur> { inherit pkgs; }; };
}
