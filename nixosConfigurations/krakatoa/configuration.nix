{ inputs, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    inputs.disko.nixosModules.disko
  ];

  networking.hostName = "krakatoa";
  networking.domain = "hamcorp.net";
  networking.hostId = "b014b166";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "22.11";
}
