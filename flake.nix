{
  inputs.nixpkgs.url = "nixpkgs/nixos-23.11";

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

  inputs.homeage.url = "github:jordanisaacs/homeage";
  inputs.homeage.inputs.nixpkgs.follows = "nixpkgs";

  inputs.terranix.url = "github:terranix/terranix";
  inputs.terranix.inputs.nixpkgs.follows = "nixpkgs";

  inputs.kit.url = "github:tvlfyi/kit";
  inputs.kit.flake = false;

  outputs =
    { self
    , darwin
    , deploy-rs
    , flake-utils
    , home-manager
    , nixos-generators
    , nixpkgs
    , terranix
    , kit
    , ...
    }@inputs:
    let
      mkTree = import ./lib/mkTree.nix { };
      root = mkTree { inherit inputs; system = "invalid-system";};

      mkNixosDeploy = hostname:
        let
          nixos = self.nixosConfigurations.${hostname};
          system = nixos.pkgs.system;
          activate = inputs.deploy-rs.lib.${system}.activate.nixos nixos;
        in
        {
          hostname = "${hostname}.platypus-banana.ts.net";
          user = "root";
          sshUser = "root";
          profiles.system.path = activate;
        };

    in
    {
      nixosConfigurations = root.lib.cleanReadTreeAttrs root.nixosConfigurations;

      deploy.nodes.router = mkNixosDeploy "router";
      deploy.nodes.nas = mkNixosDeploy "nas";
      deploy.nodes.vader = mkNixosDeploy "vader";
      deploy.nodes.thumper = mkNixosDeploy "thumper";

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
        realSystem = if system == "x86_64-darwin" then "aarch64-darwin" else system;
        root = mkTree { inherit inputs; system = realSystem; };
      in
      {
        devShells = root.lib.cleanReadTreeAttrs root.devShells;
        apps = root.lib.cleanReadTreeAttrs root.apps;

        # Super mega hack - `nix flake show` complains if packages.<system>.homeConfigurations
        # is not a derivation. So appease it by merging in pkgs.hello.
        packages.homeConfigurations = root.pkgs.hello // root.homeConfigurations;
      }
      );
}
