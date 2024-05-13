{ ... }:
{ system, inputs }:
let
  readTree = import "${inputs.kit}/readTree" { };

  mkPkgs = system: import inputs.nixpkgs {
    localSystem = system;
    config = {
      allowUnfree = true;
    };
  };

  mkArgs = system: {
    pkgs = mkPkgs system;
    root = mkRoot system;
    inherit inputs;
  };

  mkRoot = system: let
    args = mkArgs system;
    path = ../.;
    root = readTree { inherit args path; };
  in root // args;

in mkRoot system