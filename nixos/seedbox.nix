{ lib, pkgs, config, ... }:
with lib;                      
let
  cfg = config.services.seedbox;
in {
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

      services."rsync-net-sshfs" = {
        wantedBy = [ "multi-user.target" ]; 
        after = [ "network.target" ];
        before = ["sonarr.service" "radarr.service" "transmission.service"];
        description = "Start SSHFs before radarr, sonarr, transmission";
        serviceConfig = {
          ExecStart = "${pkgs.sshfs}/bin/sshfs fm1105@fm1105.rsync.net:media /media -f -o allow_other,default_permissions,reconnect,ServerAliveInterval=15,idmap=file,uidfile=${./idmap},gidfile=${./idmap}";
        };
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

    # Expose transmission behind basic auth
    services.nginx.virtualHosts."transmission.adh.io" = {
      enableACME = true;
      forceSSL = true;
      basicAuthFile = cfg.basicAuthFile;
      locations."/" = {
        proxyPass = "http://${cfg.netNamespaceSeedboxIP}:8080";
        proxyWebsockets = true;
      };
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
      forceSSL = true;
      basicAuthFile = cfg.basicAuthFile;
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

    services.nginx.virtualHosts."sonarr.adh.io" = {
      enableACME = true;
      forceSSL = true;
      basicAuthFile = cfg.basicAuthFile;
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

    services.nginx.virtualHosts."radarr.adh.io" = {
      enableACME = true;
      forceSSL = true;
      basicAuthFile = cfg.basicAuthFile;
      locations."/" = {
        proxyPass = "http://127.0.0.1:7878";
        proxyWebsockets = true;
      };
    };

    # Port 9696 by default
    services.prowlarr.enable = true;

    services.nginx.virtualHosts."prowlarr.adh.io" = {
      enableACME = true;
      forceSSL = true;
      basicAuthFile = cfg.basicAuthFile;
      locations."/" = {
        proxyPass = "http://127.0.0.1:9696";
        proxyWebsockets = true;
      };
    };

    services.nginx.virtualHosts."media.adh.io" = {
      forceSSL = true;
      enableACME = true;
      basicAuthFile = cfg.basicAuthFile;
      locations."/"= {
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
      };
    };

    users.groups = mkIf (cfg.group == "media") {
      media = {};
    };

    networking.wireguard.interfaces."${cfg.netNamespaceName}" = {
      ips = cfg.wgIps;
      listenPort = cfg.wgListenPort;
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
