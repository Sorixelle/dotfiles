let
  pins = import ../npins;
in

[
  (import ./packages pins)
  (import pins.emacs-overlay)
  (import "${pins.git-diffie}/overlay.nix")
]
