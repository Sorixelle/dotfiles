{ ... }:

{
  services.picom = {
    enable = true;
    experimentalBackends = true;
    backend = "glx";
    vSync = true;

    fade = true;
    fadeDelta = 4;

    shadow = true;
    shadowOffsets = [ (-10) (-10) ];
    shadowOpacity = 0.7;

    opacityRules = [ "90:class_g = 'Emacs'" ];

    settings = {
      blur = {
        method = "dual_kawase";
        strength = 5;
      };
      blur-background-exclude = [ "class_g = 'slop'" ];
    };
  };
}
