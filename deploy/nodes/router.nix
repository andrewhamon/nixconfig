{ root, ... }:
root.lib.mkNixosDeploy { name = "router"; hostname = "10.69.42.1"; }
