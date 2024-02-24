{ config, pkgs, inputs, lib, homeDirectory, username, pkgsUnstable, ... }:
{
  imports = [
    ./home.nix
    ./desktop.nix
  ];

  home.packages = with pkgs; [
    lima
    colima
    docker
  ];
}
