{
  description = "My NixOS configuration for all of my systems.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    lix = {
      url = "https://git.lix.systems/lix-project/lix/archive/main.tar.gz";
      flake = false;
    };
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/main.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.lix.follows = "lix";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    emacs = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-diffie = {
      url = "github:the6p4c/git-diffie";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprlock = {
      url = "github:hyprwm/hyprlock";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    musnix = {
      url = "github:musnix/musnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nur.url = "github:nix-community/NUR";
    shadower.url = "github:n3oney/shadower";
    tree-sitter-astro = {
      url = "github:virchau13/tree-sitter-astro";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      flake-utils,
      nix-darwin,
      nixpkgs,
      pre-commit-hooks,
      ...
    }@inputs:
    with nixpkgs.lib;
    let
      genSystems = genAttrs flake-utils.lib.defaultSystems;

      genNixpkgsConfig = system: {
        inherit system;
        config = import ./nixpkgs/config.nix;
        overlays = [
          inputs.emacs.overlay
          inputs.git-diffie.overlays.default
          inputs.hyprlock.overlays.default
          inputs.nur.overlays.default
          # inputs.shadower.overlay
          inputs.tree-sitter-astro.overlays.default
          self.overlay
        ];
      };

      pkgsBySystem = genSystems (system: import nixpkgs (genNixpkgsConfig system));

      # Generate a boilerplate system with a machine specific config.
      defineSystem =
        let
          mkSystem = makeOverridable nixosSystem;
        in
        name:
        { system, config }:
        nameValuePair name (mkSystem {
          inherit system;

          modules = [
            nixpkgs.nixosModules.notDetected
            inputs.home-manager.nixosModules.home-manager
            inputs.lix-module.nixosModules.default
            inputs.musnix.nixosModules.default

            (import ./system/common.nix)

            (import config)
          ];

          specialArgs = {
            inherit inputs name;
            flakePkgs = pkgsBySystem."${system}";
          };
        });
    in
    {
      nixosConfigurations = mapAttrs' defineSystem {
        sapphire = {
          system = "x86_64-linux";
          config = ./system/sapphire.nix;
        };
        tanzanite = {
          system = "x86_64-linux";
          config = ./system/tanzanite.nix;
        };
      };

      darwinConfigurations = {
        bauxite = nix-darwin.lib.darwinSystem {
          modules = [
            inputs.lix-module.nixosModules.default
            inputs.home-manager.darwinModules.home-manager
            { nixpkgs.pkgs = pkgsBySystem.aarch64-darwin; }

            ./system-darwin/bauxite.nix
          ];
        };
      };

      overlay = import ./nixpkgs/packages;

      devShell = genSystems (
        s:
        with pkgsBySystem."${s}";
        mkShell {
          name = "srxl-dotfiles";

          nativeBuildInputs = [
            nixd
            nixfmt-rfc-style
            (import (fetchzip {
              url = "https://github.com/andir/npins/archive/refs/heads/master.tar.gz";
              hash = "sha256-/FTE/lDICJnXr4JbxaA+9mwM0sSF5++/XaYR+S2pFdA=";
            }) { system = s; })
          ];

          shellHook = ''
            ${self.checks.${s}.pre-commit-check.shellHook}
          '';
        }
      );

      checks = genSystems (s: {
        pre-commit-check = pre-commit-hooks.lib.${s}.run {
          src = builtins.path {
            path = ./.;
            name = "dotfiles";
          };
          hooks = {
            nixfmt-rfc-style.enable = true;
          };
        };
      });
    };
}
