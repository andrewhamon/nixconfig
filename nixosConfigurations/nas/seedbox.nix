{ lib, pkgs, config, inputs, ... }:
with lib;
let
  cfg = config.services.seedbox;
  protectWithAuthfish = inputs.authfish.lib.protectWithAuthfish config;
in
{
  imports = [
    ./namespaced-wg.nix
  ];

  options.services.seedbox = {
    enable = mkEnableOption "Seedbox services";
    user = mkOption {
      type = types.str;
      default = "media";
    };
    group = mkOption {
      type = types.str;
      default = "media";
    };
    netNamespaceName = mkOption {
      type = types.str;
      default = "seedbox";
    };
    netNamespaceHostIP = mkOption {
      type = types.str;
      example = "10.69.44.1";
    };
    netNamespaceSeedboxIP = mkOption {
      type = types.str;
      example = "10.69.44.2";
    };
    wgInterfaceName = mkOption {
      type = types.str;
      default = "seedbox";
    };
    wgIps = mkOption {
      type = types.listOf types.str;
    };
    wgPrivateKeyFile = mkOption {
      type = types.str;
    };
    wgPeerPublicKey = mkOption {
      type = types.str;
    };
    wgPeerEndpoint = mkOption {
      type = types.str;
    };
    basicAuthFile = mkOption {
      type = types.str;
    };
    transmissionPeerPort = mkOption {
      type = types.int;
    };
  };

  # Set up transmission
  config = mkIf cfg.enable {
    services.namespaced-wg.enable = true;
    services.namespaced-wg.name = cfg.netNamespaceName;
    services.namespaced-wg.ips = cfg.wgIps;
    services.namespaced-wg.peerPublicKey = cfg.wgPeerPublicKey;
    services.namespaced-wg.peerEndpoint = cfg.wgPeerEndpoint;
    services.namespaced-wg.privateKeyFile = cfg.wgPrivateKeyFile;
    services.namespaced-wg.guestPortalIp = cfg.netNamespaceSeedboxIP;
    services.namespaced-wg.hostPortalIp = cfg.netNamespaceHostIP;


    # services.transmission = {
    #   enable = false;
    #   user = cfg.user;
    #   group = cfg.group;
    #   settings = {
    #     rpc-bind-address = "0.0.0.0";
    #     rpc-port = 8080;
    #     rpc-host-whitelist-enabled = false;
    #     rpc-whitelist-enabled = false;
    #     rpc-authentication-required = false;
    #     watch-dir-enabled = true;
    #     peer-port = cfg.transmissionPeerPort;
    #     ratio-limit-enabled = true;
    #     ratio-limit = 0;
    #   };
    # };

    # # Run transmission in a special network namespace. See the wireguard config down below
    # systemd.services.transmission = config.services.namespaced-wg.systemdMods;

    services.jellyfin.enable = true;
    services.jellyseerr.enable = true;

    # https://github.com/NixOS/nixpkgs/issues/152008#issuecomment-1029281497
    # systemd.services."jellyfin".serviceConfig = {
    #   DeviceAllow = pkgs.lib.mkForce [ "char-drm rw" "char-nvidia-frontend rw" "char-nvidia-uvm rw" ];
    #   PrivateDevices = pkgs.lib.mkForce false;
    #   RestrictAddressFamilies = pkgs.lib.mkForce [ "AF_UNIX" "AF_NETLINK" "AF_INET" "AF_INET6" ];
    # };

    services.nginx.virtualHosts."jellyfin.adh.io" = {
      enableACME = true;
      onlySSL = true;
      locations."/" = {
        proxyPass = "http://localhost:8096";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header   Host               $host;
          proxy_set_header   X-Real-IP          $proxy_protocol_addr;
          proxy_set_header   X-Forwarded-Proto  $scheme;
          proxy_set_header   X-Forwarded-For    $proxy_protocol_addr;
        '';
      };
    };

    services.nginx.virtualHosts."requests.adh.io" = {
      enableACME = true;
      onlySSL = true;
      locations."/" = {
        proxyPass = "http://localhost:5055";
        proxyWebsockets = true;
      };
    };

    services.nginx.virtualHosts."transmission.adh.io" = protectWithAuthfish {
      enableACME = true;
      onlySSL = true;
      locations."/" = {
        proxyPass = "http://${cfg.netNamespaceSeedboxIP}:8080";
        proxyWebsockets = true;
      };
    };

    services.nzbget = {
      enable = true;
      user = cfg.user;
      group = cfg.group;
    };

    # systemd.services.nzbget = config.services.namespaced-wg.systemdMods;

    services.nginx.virtualHosts."nzb.adh.io" = protectWithAuthfish {
      enableACME = true;
      onlySSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:6789";
        proxyWebsockets = true;
      };
    };

    # Sonarr, Radarr, Prowlarr configs. These don't need to be behind a VPN.
    # Most config happens in the UI, not much to see here.

    # Port 8989 by default
    services.sonarr = {
      enable = true;
      user = cfg.user;
      group = cfg.group;
    };

    services.nginx.virtualHosts."sonarr.adh.io" = protectWithAuthfish {
      enableACME = true;
      onlySSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8989";
        proxyWebsockets = true;
      };
    };

    # Enable radarr
    # Port 7878 by default
    services.radarr = {
      enable = true;
      user = cfg.user;
      group = cfg.group;
    };

    services.nginx.virtualHosts."radarr.adh.io" = protectWithAuthfish {
      enableACME = true;
      onlySSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:7878";
        proxyWebsockets = true;
      };
    };

    # Enable bazarr
    # Port 6767 by default
    services.bazarr = {
      enable = true;
      user = cfg.user;
      group = cfg.group;
    };

    services.nginx.virtualHosts."bazarr.adh.io" = protectWithAuthfish {
      enableACME = true;
      onlySSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:6767";
        proxyWebsockets = true;
      };
    };

    # Port 9696 by default
    services.prowlarr.enable = true;

    services.nginx.virtualHosts."prowlarr.adh.io" = protectWithAuthfish {
      enableACME = true;
      onlySSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:9696";
        proxyWebsockets = true;
      };
    };

    services.nginx.virtualHosts."media.adh.io" = protectWithAuthfish {
      enableACME = true;
      onlySSL = true;
      locations."/" = {
        root = "/media";
        extraConfig = ''
          autoindex on;
          autoindex_exact_size off;
          autoindex_localtime on;
          dav_ext_methods PROPFIND OPTIONS;
        '';
      };
    };

    users.users = mkIf (cfg.user == "media") {
      media = {
        isNormalUser = true;
        group = cfg.group;
        uid = 1002;
      };
    };

    users.groups = mkIf (cfg.group == "media") {
      media = {
        gid = 993;
      };
    };
  };
}
