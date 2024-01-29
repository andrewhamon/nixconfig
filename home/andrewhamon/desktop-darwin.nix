{ config, pkgs, inputs, lib, homeDirectory, username, pkgsUnstable, ... }:
{
  imports = [
    ./home.nix
    ./desktop.nix
  ];
}
