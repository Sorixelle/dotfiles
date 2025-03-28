{ buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "go-grip";
  version = "0.5.6";

  src = fetchFromGitHub {
    owner = "chrishrb";
    repo = "go-grip";
    rev = "v${version}";
    hash = "sha256-c3tl5nALPqIAMSqjbbQDi6mN6M1mKJvzxxDHcj/QyuY=";
  };

  vendorHash = "sha256-aU6vo/uqJzctD7Q8HPFzHXVVJwMmlzQXhAA6LSkRAow=";
}
