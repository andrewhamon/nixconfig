{ root, ... }:
root.lib.mkNixosConfiguration {
  modules = [
    ./configuration.nix
  ];
}