{ inputs, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    inputs.disko.nixosModules.disko
  ];

  networking.hostName = "krakatoa";
  networking.domain = "hamcorp.net";
  networking.hostId = "b014b166";

  systemd.network.enable = true;
  networking.useNetworkd = true;
  systemd.network.config.dhcpV4Config.DUIDType = "link-layer";
  boot.initrd.systemd.network.config.dhcpV4Config.DUIDType = "link-layer";
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.emergencyAccess = true;
  boot.initrd.systemd.initrdBin = [ pkgs.iproute2 pkgs.unixtools.nettools ];
  boot.initrd.network = {
    enable = true;
    ssh.enable = true;
    ssh.hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
    ssh.port = 2222;
  };

  system.stateVersion = "22.11";
}
