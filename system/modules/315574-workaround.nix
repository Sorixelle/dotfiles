# TODO: delete when https://github.com/NixOS/nixpkgs/issues/315574 is solved

{ lib, options, ... }: {
  options.system.nixos.codeName = lib.mkOption { readOnly = false; };
  config.system.nixos.codeName = let
    codeName = options.system.nixos.codeName.default;
    renames."Vicuña" = "Vicuna";
  in renames."${codeName}" or (throw "Unknown `codeName`: ${codeName}");
}
