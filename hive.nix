{ inputs }:
{
  meta = {
    nixpkgs = import inputs.nixpkgs { };
    specialArgs = { inherit inputs; };
  };
  defaults.imports = [ ./hosts/defaults/configuration.nix ];
  nas.imports = [ ./hosts/nas/configuration.nix ];
  router.imports = [ ./hosts/router/configuration.nix ];
  # gollum.imports = [ ./hosts/gollum/configuration.nix ];
}
