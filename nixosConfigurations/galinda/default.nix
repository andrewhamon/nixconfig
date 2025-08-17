{ root, ... }:
root.lib.mkNixosConfiguration {
  modules = [
    root.nixosModules.shared
    root.nixosModules.steam
    ./configuration.nix
    ./disko.nix
  ];
}
