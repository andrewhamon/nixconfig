{ root, ... }:
root.lib.mkNixosConfiguration {
  modules = [
    ../../hosts/defaults/configuration.nix
    ./configuration.nix
  ];
}