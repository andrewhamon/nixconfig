{
  inputs.nixpkgs.url = "nixpkgs/nixos-22.11";
  
  outputs = { self, nixpkgs}: {
    nixosConfigurations.nas = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./nas/configuration.nix ];
    };
    nixosConfigurations.router = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./router/configuration.nix ];
    };
  };
}
