{ root, inputs, ... }:
hostname:
let
  nixos = root.nixosConfigurations.${hostname};
  system = nixos.pkgs.system;
  activate = inputs.deploy-rs.lib.${system}.activate.nixos nixos;
in
{
  hostname = "${hostname}.platypus-banana.ts.net";
  user = "root";
  sshUser = "root";
  profiles.system.path = activate;
}