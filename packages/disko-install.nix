{ pkgs, inputs, ... }:
if pkgs.stdenv.isDarwin then pkgs.hello else inputs.disko.packages."${pkgs.stdenv.hostPlatform.system}".disko-install
