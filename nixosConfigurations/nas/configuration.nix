{ config, pkgs, inputs, lib, ... }:
{
  imports =
    [
      ./acme.nix
      ./hardware-configuration.nix
      ./jwst.nix
      ./nginx-defaults.nix
      ./restic.nix
      ./seedbox.nix
      ./smart-home.nix
      ./users.nix
      ./vtt/vtt.nix
      ./adh-io.nix
      inputs.authfish.nixosModules.default
      # inputs.nvidia-patch.nixosModules.default
    ];
  boot.loader.systemd-boot.enable = true;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # hardware.nvidia.patch.enable = true;
  hardware.nvidia.open = true;

  environment.systemPackages = with pkgs; [
    smartmontools
  ];

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.enable = true;

  services.authfish.enable = true;
  services.authfish.domains = [ ".adh.io" ];
  services.authfish.virtualHostName = "login.adh.io";
  services.authfish.enableACME = true;
  services.authfish.forceSSL = true;

  services.vtt.enable = true;
  services.vtt.deployKeyAgeFile = ../../secrets/vtt_deploy_id_ed25519.age;
  services.vtt.virtualHostName = "vtt.adh.io";
  services.vtt.enableACME = true;
  services.vtt.forceSSL = true;
  services.vtt.serviceUserAuthorizedKeys = [
    # Steven
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM4g7jMEeIdC2kBUJhAzlsytXEJcAFADQ7lDgm6OgfkK"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMthdXEUzb45EhLormneQq7ue145ObRJt0MyVWjcKSlT"

    # Zach
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDONff0YGHxbGbW0FFZhnniARrPOQEgtZkZ3LNwYQSl8"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKsM/xhozqXI+OOVmPOfPqGY57SavqKJxnO3MrQWsPxP"
  ];

  age.secrets.mulvad.file = ../../secrets/mulvad.age;

  services.seedbox.enable = true;
  services.seedbox.netNamespaceHostIP = "10.69.44.1";
  services.seedbox.netNamespaceSeedboxIP = "10.69.44.2";
  services.seedbox.wgIps = [ "10.67.187.190/32" "fc00:bbbb:bbbb:bb01::4:bbbd/128" ];
  services.seedbox.wgPrivateKeyFile = config.age.secrets.mulvad.path;
  services.seedbox.wgPeerPublicKey = "m0PSpvahFXuYOtGZ9hFAMErzKW7vhwqyd82rw+yBHz0=";
  services.seedbox.wgPeerEndpoint = "66.115.165.215:51820";
  services.seedbox.transmissionPeerPort = 57942;

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.devNodes = "/dev/";
  # boot.zfs.package = pkgs.linuxPackages_6_11.zfs_unstable;

  services.zfs.trim.enable = true;
  services.zfs.autoScrub.enable = true;
  services.zfs.autoScrub.pools = [ "rpool" "tank" ];
  boot.kernelPackages = pkgs.linuxPackages_6_6;

  networking.hostName = "nas";
  networking.domain = "lan.adh.io";
  networking.hostId = "e20e1d8d";

  networking.useDHCP = true;
  networking.interfaces.enp66s0f0.useDHCP = true;

  nix.settings.trusted-users = [
    "root"
    "remotebuilder"
  ];

  services.nginx.enable = true;
  services.nginx.statusPage = true;

  networking.firewall.allowedTCPPorts = [ 80 443 5000 ];

  # See https://nixos.org/manual/nixos/stable/options.html#opt-system.stateVersion
  system.stateVersion = "22.05"; # Did you read the comment?
}
