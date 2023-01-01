{
  inputs.nixpkgs.url = "nixpkgs/nixos-22.11";
  
  outputs = { self, nixpkgs}: {
    colmena = {
      meta = {
        nixpkgs = import nixpkgs {
          system = "x86_64-linux";
          overlays = [];
        };
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
  };
}
