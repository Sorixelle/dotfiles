{ writers }:

writers.writeFishBin "rebuild" (builtins.readFile ./script.fish)
