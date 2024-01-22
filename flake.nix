{
  inputs.nixpkgs.url = "nixpkgs/nixos-23.11";

  inputs.nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

  inputs.darwin.url = "github:lnl7/nix-darwin/master";
  inputs.darwin.inputs.nixpkgs.follows = "nixpkgs";

  inputs.home-manager.url = "github:nix-community/home-manager/release-23.11";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.agenix.url = "github:ryantm/agenix";
  inputs.agenix.inputs.nixpkgs.follows = "nixpkgs";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.nil.url = "github:oxalica/nil";

  inputs.nixos-generators.url = "github:nix-community/nixos-generators";
  inputs.nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

  inputs.authfish.url = "github:andrewhamon/authfish";
  inputs.authfish.inputs.nixpkgs.follows = "nixpkgs";
  inputs.authfish.inputs.flake-utils.follows = "flake-utils";

  inputs.nvidia-patch.url = "github:arcnmx/nvidia-patch.nix";
  inputs.nvidia-patch.inputs.nixpkgs.follows = "nixpkgs";

  inputs.deploy-rs.url = "github:serokell/deploy-rs";
  inputs.deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
  inputs.deploy-rs.inputs.utils.follows = "flake-utils";

  inputs.hyprland.url = "github:hyprwm/Hyprland";
  # inputs.hyprland.inputs.nixpkgs = "nixpkgs";

  inputs.roc.url = "github:roc-lang/roc";

  outputs =
    { self
    , darwin
    , deploy-rs
    , flake-utils
    , nixos-generators
    , nixpkgs
    , ...
    }@inputs: let
      mkPkgsUnstable = system: import inputs.nixpkgs-unstable {
          config.allowUnfree = true;
          system = system;
        };
    in {
      darwinConfigurations."andrewhamon-NNF39W2LMJ-mbp" = darwin.lib.darwinSystem rec {
        system = "aarch64-darwin";
        specialArgs = { inherit inputs; pkgsUnstable = mkPkgsUnstable system; };
        modules = [
          ./hosts/andrewhamon-NNF39W2LMJ-mbp/darwin-configuration.nix
        ];
      };
      darwinConfigurations."andrewhamon-V269DF914J-mbp" = darwin.lib.darwinSystem rec {
        system = "aarch64-darwin";
        specialArgs = { inherit inputs; pkgsUnstable = mkPkgsUnstable system; };
        modules = [
          ./hosts/andrewhamon-V269DF914J-mbp/darwin-configuration.nix
        ];
      };
      nixosConfigurations."nas" = inputs.nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        pkgs = import inputs.nixpkgs {
          config.allowUnfree = true;
          system = "x86_64-linux";
        };
        specialArgs = { inherit inputs; pkgsUnstable = mkPkgsUnstable system; };
        modules = [
          ./hosts/defaults/configuration.nix
          ./hosts/nas/configuration.nix
        ];
      };

      nixosConfigurations."vader" = inputs.nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        pkgs = import inputs.nixpkgs {
          config.allowUnfree = true;
          system = "x86_64-linux";
        };
        specialArgs = { inherit inputs; pkgsUnstable = mkPkgsUnstable system; };
        modules = [
          ./hosts/vader/configuration.nix
        ];
      };

      nixosConfigurations."thumper" = inputs.nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        pkgs = import inputs.nixpkgs {
          config.allowUnfree = true;
          system = "x86_64-linux";
        };
        specialArgs = { inherit inputs; pkgsUnstable = mkPkgsUnstable system; };
        modules = [
          ./hosts/thumper/configuration.nix
        ];
      };

      deploy.nodes.thumper = {
        hostname = "thumper.platypus-banana.ts.net";
        user = "root";
        profiles.system = {
          path = deploy-rs.lib.x86_64-linux.activate.nixos (inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = { inherit inputs; };
            modules = [
              ./hosts/thumper/configuration.nix
            ];
          });
        };
      };

      deploy.nodes.nas = {
        hostname = "nas.platypus-banana.ts.net";
        user = "root";
        profiles.system = {
          path = deploy-rs.lib.x86_64-linux.activate.nixos (inputs.nixpkgs.lib.nixosSystem rec {
            system = "x86_64-linux";
            specialArgs = { inherit inputs; pkgsUnstable = mkPkgsUnstable "x86_64-linux"; };
            modules = [
              ./hosts/defaults/configuration.nix
              ./hosts/nas/configuration.nix
            ];
          });
        };
      };

      deploy.nodes.router = {
        hostname = "router.adh.io";
        user = "root";
        profiles.system = {
          path = deploy-rs.lib.x86_64-linux.activate.nixos (inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = { inherit inputs; };
            modules = [
              ./hosts/defaults/configuration.nix
              ./hosts/router/configuration.nix
            ];
          });
        };
      };

      deploy.nodes.vader = {
        hostname = "vader.platypus-banana.ts.net";
        user = "root";
        profiles.system = {
          path = deploy-rs.lib.x86_64-linux.activate.nixos (inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = { inherit inputs; };
            modules = [
              ./hosts/vader/configuration.nix
            ];
          });
        };
      };

      installIso = nixos-generators.nixosGenerate {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/defaults/configuration.nix
        ];
        format = "install-iso";
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    } // flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;   
          };
        in
        {
          devShells.default = import ./shell.nix { inherit pkgs inputs; };
          apps.deploy = {
            type = "app";
            program = "${deploy-rs.defaultPackage.${system}}/bin/deploy";
          };
        }
      );
}
