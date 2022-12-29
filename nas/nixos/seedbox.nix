{ lib, pkgs, config, ... }:
with lib;                      
let
  cfg = config.services.seedbox;
  authfishVirtualHostBase = {
    extraConfig = ''
      auth_request /auth_request;
      error_page 401 /authfish_login;
    '';
    locations."/auth_request" = {
      proxyPass = "http://localhost:${toString config.services.authfish.port}/check";
      extraConfig = ''
        internal;
        proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
      '';
    };
    locations."/authfish_login" = {
      proxyPass = "http://localhost:${toString config.services.authfish.port}/login";
      extraConfig = ''
        auth_request off;
        proxy_set_header X-Authfish-Login-Path /authfish_login;
        proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
      '';
    };
  };

  proxyProtocolListen = [
        {
          addr = "0.0.0.0";
          port = 443;
          ssl = true;
          extraParameters = ["proxy_protocol"];
        }
      ];
  nixpkgsUnstable = import
    (builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/tarball/2da64a81275b68fdad38af669afeda43d401e94b";
      sha256 = "sha256:1k71lmzdaa48yqkmsnd22n177qmxxi4gj2qcmdbv0mc6l4f27wd0";
    })
    { };
in {
  imports = [
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
    wgListenPort = mkOption {
      type = types.int;
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
    wgPeerAllowedIps = mkOption {
      type = types.listOf types.str;
      default = [ "0.0.0.0/0" "::/0" ];
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
    services.transmission = {
      enable = true;
      user = cfg.user;
      group = cfg.group;
      settings = {
        rpc-bind-address = "0.0.0.0";
        rpc-port = 8080;
        rpc-host-whitelist-enabled = false;
        rpc-whitelist-enabled = false;
        rpc-authentication-required = false;
        watch-dir-enabled = true;
        peer-port = cfg.transmissionPeerPort;
        ratio-limit-enabled = true;
        ratio-limit = 0;
      };
    };

    # Run transmission in a special network namespace. See the wireguard config down below
    systemd = {
      services.transmission.after = ["network.target" "seedbox_netns_${cfg.netNamespaceName}.service"];
      services.transmission.bindsTo = ["seedbox_netns_${cfg.netNamespaceName}.service"];
      services.transmission.partOf = ["seedbox_netns_${cfg.netNamespaceName}.service"];
      services.transmission.serviceConfig.NetworkNamespacePath = "/var/run/netns/${cfg.netNamespaceName}";

      services."wireguard-${cfg.netNamespaceName}" = {
        after = ["network.target" "network-online.target" "seedbox_netns_${cfg.netNamespaceName}.service"];
        bindsTo = ["seedbox_netns_${cfg.netNamespaceName}.service"];
        partOf = ["seedbox_netns_${cfg.netNamespaceName}.service"];
      };

      services."seedbox_netns_${cfg.netNamespaceName}" = {
        description = "seedbox_netns network namespace";
        before = [ "network.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStop = "ip netns del ${cfg.netNamespaceName}";
        };
        script = ''
            ipCmd="${pkgs.iproute}/bin/ip"
            touch /tmp/i_was_here
            set -x

            # Delete the ns if it already exists. Mostly handy for developemt, in
            # case this setup fails partway through and leaves things in an odd
            # state.
            ($ipCmd netns list | grep ${cfg.netNamespaceName}) && $ipCmd netns delete ${cfg.netNamespaceName}

            $ipCmd netns add ${cfg.netNamespaceName}

            sleep 10

            $ipCmd link add ${cfg.netNamespaceName}_portal type veth peer host_portal
            $ipCmd link set dev host_portal netns ${cfg.netNamespaceName}

            $ipCmd addr add ${cfg.netNamespaceHostIP}/32 dev ${cfg.netNamespaceName}_portal
            $ipCmd netns exec ${cfg.netNamespaceName} $ipCmd addr add ${cfg.netNamespaceSeedboxIP}/32 dev host_portal

            $ipCmd link set dev ${cfg.netNamespaceName}_portal up
            $ipCmd route add ${cfg.netNamespaceSeedboxIP}/32 dev ${cfg.netNamespaceName}_portal

            $ipCmd netns exec ${cfg.netNamespaceName} $ipCmd link set dev host_portal up
            $ipCmd netns exec ${cfg.netNamespaceName} $ipCmd route add ${cfg.netNamespaceHostIP}/32 dev host_portal
          '';
      };
    };

    services.jellyfin.enable = true;
    services.jellyfin.package = nixpkgsUnstable.jellyfin;

    # https://github.com/NixOS/nixpkgs/issues/152008#issuecomment-1029281497
    # systemd.services."jellyfin".serviceConfig = {
    #   DeviceAllow = pkgs.lib.mkForce [ "char-drm rw" "char-nvidia-frontend rw" "char-nvidia-uvm rw" ];
    #   PrivateDevices = pkgs.lib.mkForce false;
    #   RestrictAddressFamilies = pkgs.lib.mkForce [ "AF_UNIX" "AF_NETLINK" "AF_INET" "AF_INET6" ];
    # };

    services.nginx.virtualHosts."jellyfin.adh.io" = {
      enableACME = true;
      listen = proxyProtocolListen;
      forceSSL = true;
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

    services.nginx.virtualHosts."transmission.adh.io" = {
      enableACME = true;
      listen = proxyProtocolListen;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://${cfg.netNamespaceSeedboxIP}:8080";
        proxyWebsockets = true;
      };
      extraConfig = authfishVirtualHostBase.extraConfig;
      locations."/auth_request" = authfishVirtualHostBase.locations."/auth_request";
      locations."/authfish_login" = authfishVirtualHostBase.locations."/authfish_login";
    };

    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "unrar"
    ];

    services.nzbget = {
      enable = true;
      user = cfg.user;
      group = cfg.group;
    };

    services.nginx.virtualHosts."nzb.adh.io" = {
      enableACME = true;
      listen = proxyProtocolListen;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:6789";
        proxyWebsockets = true;
      };
      extraConfig = authfishVirtualHostBase.extraConfig;
      locations."/auth_request" = authfishVirtualHostBase.locations."/auth_request";
      locations."/authfish_login" = authfishVirtualHostBase.locations."/authfish_login";
    };

    # Sonarr, Radarr, Prowlarr configs. These don't need to be behind a VPN.
    # Most config happens in the UI, not much to see here.

    # Port 8989 by default
    services.sonarr = {
      enable = true;
      user = cfg.user;
      group = cfg.group;
    };

    services.nginx.virtualHosts."sonarr.adh.io" = {
      enableACME = true;
      listen = proxyProtocolListen;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8989";
        proxyWebsockets = true;
      };
      extraConfig = authfishVirtualHostBase.extraConfig;
      locations."/auth_request" = authfishVirtualHostBase.locations."/auth_request";
      locations."/authfish_login" = authfishVirtualHostBase.locations."/authfish_login";
    };

    # Enable radarr
    # Port 7878 by default
    services.radarr = {
      enable = true;
      user = cfg.user;
      group = cfg.group;
    };

    services.nginx.virtualHosts."radarr.adh.io" = {
      enableACME = true;
      listen = proxyProtocolListen;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:7878";
        proxyWebsockets = true;
      };
      extraConfig = authfishVirtualHostBase.extraConfig;
      locations."/auth_request" = authfishVirtualHostBase.locations."/auth_request";
      locations."/authfish_login" = authfishVirtualHostBase.locations."/authfish_login";
    };

    # virtualisation.oci-containers.containers.radar1080 = {
    #   image = "linuxserver/radarr:4.1.0";
    #   ports = ["17878:7878"];
    #   volumes = [
    #     "/var/lib/radarr1080/.config/Radarr:/config"
    #     "/media/movies1080:/media/movies1080"
    #     "/home/media/downloads/dst/Movies1080:/home/media/downloads/dst/Movies1080"
    #   ];
    #   environment = {
    #     PUID = toString config.users.users.media.uid;
    #     PGID = toString config.users.groups.media.gid;
    #   };
    # };

    # services.nginx.virtualHosts."radarr1080.adh.io" = {
    #   enableACME = true;
    #   listen = proxyProtocolListen;
    #   forceSSL = true;
    #   locations."/" = {
    #     proxyPass = "http://127.0.0.1:17878";
    #     proxyWebsockets = true;
    #   };
    #   extraConfig = authfishVirtualHostBase.extraConfig;
    #   locations."/auth_request" = authfishVirtualHostBase.locations."/auth_request";
    #   locations."/authfish_login" = authfishVirtualHostBase.locations."/authfish_login";
    # };

    # Port 9696 by default
    services.prowlarr.enable = true;

    services.nginx.virtualHosts."prowlarr.adh.io" = {
      enableACME = true;
      listen = proxyProtocolListen;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:9696";
        proxyWebsockets = true;
      };
      extraConfig = authfishVirtualHostBase.extraConfig;
      locations."/auth_request" = authfishVirtualHostBase.locations."/auth_request";
      locations."/authfish_login" = authfishVirtualHostBase.locations."/authfish_login";
    };

    services.nginx.virtualHosts."media.adh.io" = {
      enableACME = true;
      listen = proxyProtocolListen;
      forceSSL = true;
      locations."/"= {
        root = "/media";
        extraConfig = ''
          autoindex on;
          autoindex_exact_size off;
          autoindex_localtime on;
          dav_ext_methods PROPFIND OPTIONS;
        '';
      };
      # extraConfig = authfishVirtualHostBase.extraConfig;

      extraConfig = ''
        auth_request /auth_request;
        error_page 401 /authfish_login;
      '';

      # Annoyingly, Infuse will always make an unauthenticated request first,
      # and then only send auth creds if the server responds with a 401 + the
      # WWW-Authenticate: Basic header. That means "secret basic auth" doesn't
      # work with Infuse. To work around that, manually set this header.
      # extraConfig = authfishVirtualHostBase.extraConfig + ''
      #   if ($http_user_agent = ""){
      #       add_header WWW-Authenticate Basic always;
      #     }
      # '';
      locations."/auth_request" = authfishVirtualHostBase.locations."/auth_request";
      locations."/authfish_login" = {
        proxyPass = "http://localhost:${toString config.services.authfish.port}/login";
        extraConfig = ''
          auth_request off;
          if ($http_user_agent = ""){
            add_header WWW-Authenticate Basic always;
          }
          proxy_set_header X-Authfish-Login-Path /authfish_login;
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

    networking.wireguard.interfaces."${cfg.netNamespaceName}" = {
      ips = cfg.wgIps;
      # listenPort = cfg.wgListenPort;
      privateKeyFile = cfg.wgPrivateKeyFile;
      interfaceNamespace = cfg.netNamespaceName;
      peers = [
        {
          publicKey = cfg.wgPeerPublicKey;
          allowedIPs = cfg.wgPeerAllowedIps;
          endpoint = cfg.wgPeerEndpoint;
        }
      ];
    };
  };
}
