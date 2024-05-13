{ pkgs, ... }:
{
  type = "app";
  program = "${pkgs.home-manager}/bin/home-manager";
}
