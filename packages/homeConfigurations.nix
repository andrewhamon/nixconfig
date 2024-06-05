{ pkgs, root, ... }:
# Super mega hack - `nix flake show` complains if packages.<system>.homeConfigurations
# is not a derivation. So appease it by merging in pkgs.hello.
pkgs.hello.overrideAttrs
  (prev: {
    passthru = (prev.passthru or { }) // root.homeConfigurations;
  })
