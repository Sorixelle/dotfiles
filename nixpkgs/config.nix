{
  allowBroken = true;
  allowUnfree = true;

  packageOverrides = pkgs: {
    nur = import <nur> { inherit pkgs; };
  };
}
