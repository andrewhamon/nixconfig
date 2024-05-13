{ root, ... }:
root.lib.mkNixosConfiguration {
  modules = [
    root.nixosModules.shared
    ./configuration.nix
  ];
}
