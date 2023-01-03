{ config, pkgs, ... }:
let
  proxyProtocolListen = [
    {
      addr = "0.0.0.0";
      port = 443;
      ssl = true;
      extraParameters = [ "proxy_protocol" ];
    }
  ];
in
{
  imports =
    [
      ./hardware-configuration.nix
      ./seedbox.nix
      ./authfish.nix
      ./users.nix
      ./smart-home.nix
      ./jwst.nix
    ];

  boot.loader.systemd-boot.enable = true;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  nixpkgs.config.packageOverrides = pkgs: {
    arc = import
      (builtins.fetchTarball {
        url = "https://github.com/arcnmx/nixexprs/archive/08a680c787becec40bb773a34ff6f7075222f003.tar.gz";
        sha256 = "sha256:056bg096r4dd93bwg6rk2m5qx1ghgzsy5df4jz9jagfk88bwmpfx";
      })
      {
        inherit pkgs;
      };
  };

  hardware.nvidia.package = pkgs.arc.packages.nvidia-patch.override {
    nvidia_x11 = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  nixpkgs.config.allowUnfree = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;

  virtualisation.docker.enable = true;
  virtualisation.docker.enableNvidia = true;
  virtualisation.oci-containers.backend = "docker";

  services.authfish.enable = true;
  services.authfish.domains = ".adh.io";

  age.secrets.mulvad.file = ../secrets/mulvad.age;

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

  networking.hostName = "nas";
  networking.domain = "lan.adh.io";
  networking.hostId = "e20e1d8d";

  services.tailscale.enable = true;

  services.octoprint.enable = true;


  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp38s0.useDHCP = true;

  networking.interfaces.enp39s0.useDHCP = false;
  networking.interfaces.enp39s0.ipv4.addresses = [{
    address = "10.69.43.2";
    prefixLength = 24;
  }];

  networking.defaultGateway.address = "10.69.43.1";
  networking.defaultGateway.interface = "enp39s0";
  networking.defaultGateway.metric = 10;

  # Virtual USB etherent from the motherboard. IPMI related. Disabling DHCP
  # since it was adding routes for 169.254.0.0/16, which seemed a bit sketchy.
  # networking.interfaces.enp42s0f3u5u3c2.useDHCP = false;

  security.acme.defaults.email = "and.ham95@gmail.com";
  security.acme.acceptTerms = true;
  services.nginx.enable = true;
  services.nginx.statusPage = true;

  networking.firewall.allowedTCPPorts = [ 80 443 8081 5000 ];


  # See https://nixos.org/manual/nixos/stable/options.html#opt-system.stateVersion
  system.stateVersion = "22.05"; # Did you read the comment?

  age.secrets.grafana.file = ../secrets/grafana.age;
  age.secrets.grafana.owner = "grafana";

  services.grafana.enable = true;
  services.grafana.settings.server.domain = "grafana.adh.io";
  services.grafana.settings.server.protocol = "http";
  services.grafana.settings.security.secret_key = "$__file{${config.age.secrets.grafana.path}}";

  services.nginx.virtualHosts."grafana.adh.io" = {
    enableACME = true;
    listen = proxyProtocolListen;
    forceSSL = true;
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
    # extraConfig = authfishVirtualHostBase.extraConfig;
    # locations."/auth_request" = authfishVirtualHostBase.locations."/auth_request";
    # locations."/authfish_login" = authfishVirtualHostBase.locations."/authfish_login";
  };

  services.prometheus = {
    enable = true;
    port = 9001;
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9002;
      };
      process = {
        enable = true;
      };
      nginx = {
        enable = true;
      };
      smartctl = {
        enable = true;
      };
    };

    scrapeConfigs = [
      {
        job_name = "nas_adh_io";
        scrape_interval = "10s";
        static_configs = [{
          targets = [
            "127.0.0.1:${toString config.services.prometheus.exporters.node.port}"
            "127.0.0.1:${toString config.services.prometheus.exporters.process.port}"
            "127.0.0.1:${toString config.services.prometheus.exporters.nginx.port}"
            "127.0.0.1:${toString config.services.prometheus.exporters.smartctl.port}"
          ];
        }];
      }
    ];
  };
}
