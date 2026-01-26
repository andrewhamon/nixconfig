{ root, inputs, ... }:
{ name, hostname ? "${name}.platypus-banana.ts.net" }:
let
  nixos = root.nixosConfigurations.${name};
  system = nixos.pkgs.stdenv.hostPlatform.system;
  activate = inputs.deploy-rs.lib.${system}.activate.nixos nixos;
in
{
  hostname = hostname;
  user = "root";
  sshUser = "root";
  profiles.system.path = activate;
}
