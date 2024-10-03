{
  description = "My NixOS configuration for all of my systems.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    lix = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    emacs = {
      url = "github:nix-community/emacs-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    nur.url = "github:nix-community/NUR";
    nixmox = {
      url = "git+https://git.isincredibly.gay/srxl/nixmox";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    musnix = {
      url = "github:musnix/musnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hypridle = {
      url = "github:hyprwm/hypridle";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprlock = {
      url = "github:hyprwm/hyprlock";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    shadower = {
      url = "github:n3oney/shadower";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wired-notify = {
      url = "github:Toqozz/wired-notify";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        rust-overlay.follows = "rust-overlay";
      };
    };
    eww = {
      url = "github:elkowar/eww";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.3.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
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
    {
      self,
      flake-utils,
      nixpkgs,
      darwin,
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
          inputs.eww.overlays.default
          inputs.hypridle.overlays.default
          inputs.hyprlock.overlays.default
          inputs.hyprland-contrib.overlays.default
          #inputs.nixmox.overlay
          inputs.nur.overlay
          #inputs.rust-overlay.overlays.default
          #inputs.shadower.overlay
          #inputs.wired-notify.overlays.default
          inputs.hyprland.overlays.default
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
            inputs.hyprland.nixosModules.default
            inputs.lix.nixosModules.default
            inputs.musnix.nixosModules.default

            (import ./system/common.nix)

            (import config)
          ];

          specialArgs = {
            inherit inputs name;
            flakePkgs = pkgsBySystem."${system}";
          };
        });

      # Like defineSystem above, but for nix-darwin (macOS) configurations
      defineDarwin =
        name:
        { system, config }:
        nameValuePair name (
          darwin.lib.darwinSystem {
            modules = [
              inputs.home-manager.darwinModule

              (import ./system-darwin/common.nix {
                inherit name inputs;
                nixpkgsConf = genNixpkgsConfig system;
              })

              (import config)
            ];
          }
        );
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

      darwinConfigurations = mapAttrs' defineDarwin {
        amethyst = {
          system = "x86_64-darwin";
          config = ./system-darwin/amethyst.nix;
        };
      };

      overlay = import ./nixpkgs/packages;

      devShell = genSystems (
        s:
        with pkgsBySystem."${s}";
        mkShell {
          name = "srxl-dotfiles";

          nativeBuildInputs = [
            nil
            nixfmt-rfc-style

            (nixos-generators.override { nix = nixVersions.latest; })
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
            # nix-linter.enable = true;
          };
        };
      });
    };
}
