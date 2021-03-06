{
  description = "My NixOS configuration for all of my systems.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    emacs = {
      url = "github:nix-community/emacs-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    nur.url = "github:nix-community/NUR";
    musnix = {
      url = "github:musnix/musnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, flake-utils, nixpkgs, darwin, pre-commit-hooks, ... }@inputs:
    with nixpkgs.lib;
    let
      genSystems = genAttrs flake-utils.lib.defaultSystems;

      genNixpkgsConfig = system: {
        inherit system;
        config = import ./nixpkgs/config.nix;
        overlays = [ inputs.nur.overlay self.overlay inputs.emacs.overlay ];
      };

      pkgsBySystem =
        genSystems (system: import nixpkgs (genNixpkgsConfig system));

      # Generate a boilerplate system with a machine specific config.
      defineSystem = let mkSystem = makeOverridable nixosSystem;
      in name:
      { system, config }:
      nameValuePair name (mkSystem {
        inherit system;

        modules = [
          nixpkgs.nixosModules.notDetected
          inputs.home-manager.nixosModules.home-manager
          inputs.musnix.nixosModules.musnix

          (import ./system/common.nix)

          (import config)
        ];

        specialArgs = {
          inherit inputs name;
          flakePkgs = pkgsBySystem."${system}";
        };
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

      overlay = import ./nixpkgs/packages;

      devShell = genSystems (s:
        with pkgsBySystem."${s}";
        mkShell {
          name = "srxl-dotfiles";

          nativeBuildInputs = [
            nix-linter
            nixfmt
            (nixos-generators.override { nix = nixUnstable; })
            rnix-lsp
          ];

          shellHook = ''
            ${self.checks.${s}.pre-commit-check.shellHook}
          '';
        });

      checks = genSystems (s: {
        pre-commit-check = pre-commit-hooks.lib.${s}.run {
          src = builtins.path {
            path = ./.;
            name = "dotfiles";
          };
          hooks = {
            nixfmt.enable = true;
            nix-linter.enable = true;
          };
        };
      });
    };
}
