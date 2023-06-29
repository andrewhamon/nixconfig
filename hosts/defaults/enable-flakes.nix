{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  nixpkgsPath = "/etc/nixpkgs/channels/nixpkgs";
in {
  # This module ensures any non-flakes nix usage gets the same version
  # of nixpkgs as this flake.
  _file = ./enable-flake.nix;

  options.nix.flakes.enable = lib.mkEnableOption "nix flakes";

  config = lib.mkIf config.nix.flakes.enable {
    nix = {
      settings.experimental-features = ["nix-command" "flakes"];

      registry.nixpkgs.flake = inputs.nixpkgs;

      nixPath = [
        "nixpkgs=${nixpkgsPath}"
      ];
    };

    systemd.tmpfiles.rules = [
      "L+ ${nixpkgsPath}     - - - - ${inputs.nixpkgs}"
    ];
  };
}
