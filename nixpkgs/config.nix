{
  allowBroken = true;
  allowUnfree = true;

  permittedInsecurePackages = [ "openssl-1.1.1t" ];

  packageOverrides = pkgs: { nur = import <nur> { inherit pkgs; }; };
}
