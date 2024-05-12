{ ... }:
{ system, inputs }:
let
  readTree = import "${inputs.kit}/readTree" { };

  mkPkgs = system: import inputs.nixpkgs { localSystem = system; };

  mkArgs = system: {
    pkgs = mkPkgs system;
    root = mkRoot system;
    inherit inputs;
  };

  mkRoot = system: readTree {
    args = mkArgs system;
    path = ../.;
  };

in mkRoot system