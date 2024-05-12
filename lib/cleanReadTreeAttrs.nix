# `nix flake show` is really picky and aborts as soon as it encounters a
# non-compliant value. This is a workaround to make it happy by removing
# some extra attrs that readTree adds.
{ pkgs, ...}:
let
  pred = name: val: name != "__readTree" && name != "__readTreeChildren";
in
attrset:
pkgs.lib.attrsets.filterAttrs pred attrset