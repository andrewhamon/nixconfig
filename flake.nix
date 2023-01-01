{
  inputs.nixpkgs.url = "nixpkgs/nixos-22.11";

  inputs.agenix.url = "github:ryantm/agenix";
  inputs.agenix.inputs.nixpkgs.follows = "nixpkgs";
  
  outputs = { self, nixpkgs, agenix }: {
    colmena = {
      meta = {
        nixpkgs = import nixpkgs {
          system = "x86_64-linux";
          overlays = [];
        };
      };
      nas = {
        deployment.targetHost = "nas.lan.adh.io";
        imports = [
          ./nas/configuration.nix
          agenix.nixosModule
        ];
      };
      router = {
        deployment.targetHost = "router.adh.io";
        imports = [
          ./router/configuration.nix
          agenix.nixosModule
        ];
      };
    };
  };
}
