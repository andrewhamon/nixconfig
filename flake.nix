{
  inputs.nixpkgs.url = "nixpkgs/nixos-22.11";

  inputs.darwin.url = "github:lnl7/nix-darwin/master";
  inputs.darwin.inputs.nixpkgs.follows = "nixpkgs";

  inputs.home-manager.url = "github:nix-community/home-manager/release-22.05";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.agenix.url = "github:ryantm/agenix";
  inputs.agenix.inputs.nixpkgs.follows = "nixpkgs";

  inputs.homeage.url = "github:jordanisaacs/homeage";
  inputs.homeage.inputs.nixpkgs.follows = "nixpkgs";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.rnix-lsp.url = "github:nix-community/rnix-lsp";
  inputs.rnix-lsp.inputs.nixpkgs.follows = "nixpkgs";
  inputs.rnix-lsp.inputs.utils.follows = "flake-utils";

  inputs.nixos-generators.url = "github:nix-community/nixos-generators";
  inputs.nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

  outputs =
    { self
    , agenix
    , darwin
    , flake-utils
    , home-manager
    , homeage
    , nixpkgs
    , rnix-lsp
    , nixos-generators
    ,
    }: {
      colmena = {
        meta = {
          nixpkgs = import nixpkgs {
            system = "x86_64-linux";
            overlays = [ ];
          };
        };
        defaults = {
          imports = [
            agenix.nixosModule
            ./common/configuration.nix
          ];
        };
        nas = {
          deployment.targetHost = "nas.lan.adh.io";
          imports = [ ./nas/configuration.nix ];
        };
        router = {
          deployment.targetHost = "router.adh.io";
          imports = [ ./router/configuration.nix ];
        };
      };
      darwinConfigurations."andrewhamon-NNF39W2LMJ-mbp" =
        let
          specialArgs = {
            extraFlakes = {
              homeageModule = homeage.homeManagerModules.homeage;
            };
          };
        in
        darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            ./mac/darwin-configuration.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.andrewhamon = import ./mac/home.nix;
              home-manager.extraSpecialArgs = specialArgs;
            }
          ];
        };
    } // flake-utils.lib.eachDefaultSystem
      (system:
      let
        pkgs = import nixpkgs { inherit system; };
        agenixPkg = agenix.defaultPackage."${system}";
        rnix-lspPkg = rnix-lsp.defaultPackage."${system}";
      in
      {
        devShells.default = import ./shell.nix { inherit pkgs agenixPkg rnix-lspPkg; };
      }
      ) // {
      packages.x86_64-linux = {
        installIso = nixos-generators.nixosGenerate {
          system = "x86_64-linux";
          modules = [
            ./common/configuration.nix
          ];
          format = "install-iso";
        };
      };
    };
}
