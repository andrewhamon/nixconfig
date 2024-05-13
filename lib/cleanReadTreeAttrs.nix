# `nix flake show` is really picky and aborts as soon as it encounters a
# non-compliant value. This is a workaround to make it happy by removing
# some extra attrs that readTree adds.
{ inputs, ... }:
let
  pred = name: val: name != "__readTree" && name != "__readTreeChildren";
in
attrset:
inputs.nixpkgs.lib.attrsets.filterAttrs pred attrset
