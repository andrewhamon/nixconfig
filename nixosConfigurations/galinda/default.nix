{ root, ... }:
root.lib.mkNixosConfiguration {
  modules = [
    root.nixosModules.shared
    root.nixosModules.steam
    root.nixosModules._1password
    ./configuration.nix
    ./disko.nix
  ];
}
