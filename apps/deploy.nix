{ pkgs, inputs, ... }:
{
  type = "app";
  program = "${inputs.deploy-rs.defaultPackage.${pkgs.system}}/bin/deploy";
}
