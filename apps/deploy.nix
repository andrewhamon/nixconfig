{ pkgs, ... }:
{
  type = "app";
  program = "${pkgs.deploy-rs}/bin/deploy";
}
