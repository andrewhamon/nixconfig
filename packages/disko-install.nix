{ pkgs, inputs, ... }:
inputs.disko.packages."${pkgs.system}".disko-install
