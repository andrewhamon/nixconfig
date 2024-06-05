{
  inputs.nixpkgs.url = "nixpkgs/nixos-24.05";

  inputs.darwin.url = "github:lnl7/nix-darwin/master";
  inputs.darwin.inputs.nixpkgs.follows = "nixpkgs";

  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.agenix.url = "github:ryantm/agenix";
  inputs.agenix.inputs.nixpkgs.follows = "nixpkgs";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.nil.url = "github:oxalica/nil";

  inputs.nixos-generators.url = "github:nix-community/nixos-generators";
  inputs.nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

  inputs.authfish.url = "github:andrewhamon/authfish";

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
    , deploy-rs
    , flake-utils
    , ...
    }@inputs:
    let
      mkTree = import ./lib/mkTree.nix { };
    in
    {
      root = mkTree { inherit inputs; system = "invalid-system"; };
      nixosConfigurations = self.root.lib.cleanReadTreeAttrs self.root.nixosConfigurations;
      deploy = self.root.deploy;
    } // flake-utils.lib.eachDefaultSystem
      (system:
      let
        realSystem = if system == "x86_64-darwin" then "aarch64-darwin" else system;
        root = mkTree { inherit inputs; system = realSystem; };
      in
      {
        devShells = root.lib.cleanReadTreeAttrs root.devShells;
        apps = root.lib.cleanReadTreeAttrs root.apps;
        packages = root.lib.cleanReadTreeAttrs root.packages;
      }
      );
}
