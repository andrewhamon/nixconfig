{ self
, agenix
, authfish
, nixpkgs
, ...
}@inputs:
{
  meta = {
    nixpkgs = import nixpkgs { };
    specialArgs = {
      inherit inputs;
    };
  };
  defaults = {
    imports = [
      agenix.nixosModule
      ./common/configuration.nix
    ];
  };
  nas = {
    deployment.targetHost = "nas.platypus-banana.ts.net";
    nixpkgs.system = "x86_64-linux";
    imports = [
      authfish.nixosModules.default
      ./nas/configuration.nix
    ];
  };
  router = {
    deployment.targetHost = "router.adh.io";
    nixpkgs.system = "x86_64-linux";
    imports = [ ./router/configuration.nix ];
  };
}
