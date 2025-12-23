{ pkgs, inputs, ... }:
if pkgs.stdenv.isDarwin then pkgs.hello else inputs.disko.packages."${pkgs.system}".disko-install
