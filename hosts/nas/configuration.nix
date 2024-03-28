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

  services.zfs.trim.enable = true;
  services.zfs.autoScrub.enable = true;
  services.zfs.autoScrub.pools = [ "rpool" "tank" ];
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

  networking.hostName = "nas";
  networking.domain = "lan.adh.io";
  networking.hostId = "e20e1d8d";

  services.octoprint.enable = true;


  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp38s0.useDHCP = true;
  networking.interfaces.enp45s0f1np1.useDHCP = true;

  # networking.interfaces.enp39s0.useDHCP = false;
  # networking.interfaces.enp39s0.ipv4.addresses = [{
  #   address = "10.69.43.2";
  #   prefixLength = 24;
  # }];

  # networking.defaultGateway.address = "10.69.43.1";
  # networking.defaultGateway.interface = "enp39s0";
  # networking.defaultGateway.metric = 10;

  # Virtual USB etherent from the motherboard. IPMI related. Disabling DHCP
  # since it was adding routes for 169.254.0.0/16, which seemed a bit sketchy.
  # networking.interfaces.enp42s0f3u5u3c2.useDHCP = false;

  nix.settings.trusted-users = [
    "root"
    "remotebuilder"
  ];

  services.nginx.enable = true;
  services.nginx.statusPage = true;

  networking.firewall.allowedTCPPorts = [ 80 443 5000 ];

  # See https://nixos.org/manual/nixos/stable/options.html#opt-system.stateVersion
  system.stateVersion = "22.05"; # Did you read the comment?

  age.secrets.grafana.file = ../../secrets/grafana.age;
  age.secrets.grafana.owner = "grafana";

  services.grafana.enable = true;
  services.grafana.settings.server.domain = "grafana.adh.io";
  services.grafana.settings.server.protocol = "http";
  services.grafana.settings.security.secret_key = "$__file{${config.age.secrets.grafana.path}}";

  services.nginx.virtualHosts."grafana.adh.io" = {
    enableACME = true;
    onlySSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header   Host               $host;
        proxy_set_header   X-Real-IP          $proxy_protocol_addr;
        proxy_set_header   X-Forwarded-Proto  $scheme;
        proxy_set_header   X-Forwarded-For    $proxy_protocol_addr;
      '';
    };
  };
}
