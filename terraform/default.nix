{ pkgs, root, inputs, ...}:
let
  terranix = inputs.terranix;
  json = terranix.lib.terranixConfiguration {
    inherit pkgs;
    modules = [ ./tf.nix ];
    extraArgs = { inherit root inputs; };
  };
in {
  inherit json;
}
