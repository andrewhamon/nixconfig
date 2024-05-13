{ root, inputs, ... }:
{ system ? "x86_64-linux", modules }:
let
  # Supply a view of root which has the correct system for this nixosSystem.
  # This has to be done because in a nix flake, nixosSystems are not specific
  # to a system, they are top-level entries. At the top level we instantiate
  # a version of root with a deliberately incorrect system which is only
  # handy for library functions, but trying to reference any packages from it
  # will fail.
  systemRoot = root.lib.mkTree {
    inherit system inputs;
  };
in
inputs.nixpkgs.lib.nixosSystem {
  inherit system modules;
  pkgs = systemRoot.pkgs;
  specialArgs = {
    root = systemRoot;
    inherit inputs;
  };
}
