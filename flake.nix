{
  description = "My NixOS cnfiguratin for all of my systems.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    emacs.url = "github:nix-community/emacs-overlay";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur.url = "github:nix-community/NUR";

    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, flake-utils, nixpkgs, darwin, ... }@inputs:
    with nixpkgs.lib;
    let
      genSystems = genAttrs flake-utils.lib.defaultSystems;

      genNixpkgsConfig = system: {
        inherit system;
        config = import ./nixpkgs/config.nix;
        overlays = self.priv.overlays."${system}";
      };

      pkgsBySystem =
        genSystems (system: import nixpkgs (genNixpkgsConfig system));

      # Generate a boilerplate system with a machine specific config.
      defineSystem = name:
        { system, config }:
        nameValuePair name (nixosSystem {
          inherit system;

          modules = [
            nixpkgs.nixosModules.notDetected
            inputs.home-manager.nixosModules.home-manager

            (import ./system/common.nix {
              inherit name;
              flakePkgs = pkgsBySystem."${system}";
            })

            (import config)
          ];

          specialArgs = { inherit inputs; };
        });

      # Like defineSystem above, but for nix-darwin (macOS) configurations
      defineDarwin = name:
        { system, config }:
        nameValuePair name (darwin.lib.darwinSystem {
          modules = [
            inputs.home-manager.darwinModule

            (import ./system-darwin/common.nix {
              inherit name inputs;
              nixpkgsConf = genNixpkgsConfig system;
            })

            (import config)
          ];
        });
    in {
      priv = {
        overlays = genSystems
          (s: [ inputs.nur.overlay self.overlay."${s}" inputs.emacs.overlay ]);
      };

      nixosConfigurations = mapAttrs' defineSystem {
        amethyst = {
          system = "x86_64-linux";
          config = ./system/amethyst.nix;
        };
      };

      darwinConfigurations = mapAttrs' defineDarwin {
        amethyst = {
          system = "x86_64-darwin";
          config = ./system-darwin/amethyst.nix;
        };
      };

      overlay = genSystems (_: import ./nixpkgs/packages);

      devShell = genSystems (s:
        with pkgsBySystem."${s}";
        mkShell {
          name = "srxl-dotfiles";
          buildInputs = [ nixfmt nixos-generators ];
        });
    };
}
