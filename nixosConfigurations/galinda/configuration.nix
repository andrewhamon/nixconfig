{ inputs, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./audio.nix
    ./hyprland.nix
    ./kde.nix
    ./streaming.nix
    ./ai.nix
    inputs.disko.nixosModules.disko
  ];

  environment.systemPackages = [
    pkgs.bambu-studio
  ];

  networking.hostName = "galinda";
  networking.domain = "hamcorp.net";
  networking.hostId = "8243f0ad";

  services.pcscd.enable = true;

  systemd.network.enable = true;
  networking.useNetworkd = true;
  systemd.network.config.dhcpV4Config.DUIDType = "link-layer";
  boot.initrd.systemd.network.config.dhcpV4Config.DUIDType = "link-layer";
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.emergencyAccess = true;
  boot.initrd.systemd.initrdBin = [ pkgs.iproute2 pkgs.unixtools.nettools ];
  # boot.initrd.network = {
  #   enable = true;
  #   ssh.enable = true;
  #   ssh.hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
  #   ssh.port = 2222;
  # };

  boot.kernelPackages = pkgs.linuxPackages_6_14;

  services.flatpak.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = true;

  hardware.graphics.enable = true;

  hardware.enableRedistributableFirmware = true;

  system.stateVersion = "24.11";
}
