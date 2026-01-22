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
  boot.initrd.systemd.initrdBin = [ pkgs.iproute2 pkgs.unixtools.net-tools ];
  boot.initrd.network = {
    enable = false;
    ssh.enable = true;
    # generate with:
    #   sudo mkdir -p /etc/secrets/initrd
    #   sudo ssh-keygen -t ed25519 -f /etc/secrets/initrd/ssh_host_ed25519_key
    ssh.hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
    ssh.port = 2222;
  };

  system.stateVersion = "25.11";
}
