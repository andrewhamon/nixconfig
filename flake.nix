{
  inputs.nixpkgs.url = "nixpkgs/nixos-22.05";
  inputs.nixpkgsUnstable.url = "nixpkgs/2da64a81275b68fdad38af669afeda43d401e94b";
  
  outputs = { self, nixpkgs, nixpkgsUnstable}: {
    nixosConfigurations.nas = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        nixpkgsUnstable = import nixpkgsUnstable { system = "x86_64-linux"; };
      };
      modules = [ ./nas/nixos/configuration.nix ];
    };
    nixosConfigurations.router = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./router/nixos/configuration.nix ];
    };
  };
}
