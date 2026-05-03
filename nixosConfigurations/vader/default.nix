{ root, ... }:
root.lib.mkNixosConfiguration {
  modules = [
    root.nixosModules.shared
    root.nixosModules._1password
    ./configuration.nix
  ];
}
