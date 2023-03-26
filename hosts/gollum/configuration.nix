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

  networking.interfaces.eno2.ipv4.addresses = [{
    address = "10.69.45.2";
    prefixLength = 24;
  }];

  networking.firewall.allowedTCPPorts = [ 5201 ];
  networking.firewall.allowedUDPPorts = [ 5201 ];

  system.stateVersion = "22.11";
}
