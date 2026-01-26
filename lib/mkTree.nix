{ ... }:
{ system, inputs }:
let
  readTree = import "${inputs.kit}/readTree" { };

  mkPkgs = system: import inputs.nixpkgs {
    localSystem = system;
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "aspnetcore-runtime-wrapped-6.0.36"
        "aspnetcore-runtime-6.0.36"
        "dotnet-sdk-wrapped-6.0.428"
        "dotnet-sdk-6.0.428"
        "1password-cli-2.32.0"
      ];
    };
  };

  mkArgs = system: {
    pkgs = mkPkgs system;
    root = mkRoot system;
    inherit inputs;
  };

  mkRoot = system:
    let
      args = mkArgs system;
      path = ../.;
      root = readTree { inherit args path; };
    in
    root // args;

in
mkRoot system
