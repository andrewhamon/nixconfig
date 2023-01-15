{ config, pkgs, ... }:

{
  deployment.targetHost = "gollum.lan.adh.io";
  nixpkgs.system = "x86_64-linux";

  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/disk/by-id/ata-Samsung_SSD_870_EVO_1TB_S6PTNZ0T323669N";

  networking.hostName = "gollum";
  networking.domain = "lan.adh.io";

  system.stateVersion = "22.11";
}
