{ inputs, ... }:
let
  dirEntries = builtins.readDir ./.;
  inherit (inputs.nixpkgs.lib) hasSuffix removeSuffix concatMapAttrs;
  isNixFile = name: type: ((hasSuffix ".nix" name) && (type == "regular") && (name != "default.nix"));
  stripDotNix = name: removeSuffix ".nix" name;
  mkPath = name: ./.  + ("/" + name);
  mapEntry = name: value: if (isNixFile name value) then { "${stripDotNix name}" = import (mkPath name); } else {};
in concatMapAttrs mapEntry dirEntries
