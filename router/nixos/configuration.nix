{ config, pkgs, ... }:

let
  hostName = "router";
  domain = "adh.io";

  # NextDNS
  dnsServers = [
    "2a07:a8c0::dc:afe8"
    "2a07:a8c1::dc:afe8"
    "45.90.28.182"
    "45.90.30.182"
  ];

  wanInterface = "enp1s0";
  lanInterface = "enp2s0";

  # Anything from the private IP space
  lanV4Address = "10.69.42.1";
  lanV4PrefixLength = 24;
  lanV4Cidr = "10.69.42.0/24";
  lanV4DhcpStart = "10.69.42.100";
  lanV4DhcpEnd = "10.69.42.200";

  nasIpAddress = "10.69.42.2";
  nasMacAddress = "00:25:90:f2:43:da";

  # "Routed /48" in tunnelbroker.net is 2001:470:4ac8::/48
  # Taking the first /64 for this subnet
  lanV6Address = "2001:470:4ac8:1::1";
  lanV6PrefixLength = 64;

  wg0V4Cidr = "10.69.43.1/24";
  wg0V6Cidr = "2001:470:4ac8:2::1/64";
  # Use something less common/blockable for wireguard. Might need to reconsider
  # once nginx supports quic/HTTP3.
  wgListenPort = 443;
  wgMullvadListenPort = 444;

  tunnelBrokerInterface = "tunnelBroker";

  tunnelBrokerAccountName = "andham95";
  tunnelBrokerTunnelID = "760000";
  tunnelBrokerUpdateKeyFile = "/etc/secrets/tunnelbroker_update_key.txt";

  # The correct values can be found in the tunnelbroker.net tunnel details
  tunnelBrokerServerV4 = "64.62.134.130";
  tunnelBrokerServerV6 = "2001:470:66:382::1";
  tunnelBrokerClientV6 = "2001:470:66:382::2";

  # This interface should have an ipv4 address that matches
  # "Client IPv4 Address" in tunnelbroker.net. Only specifying an interface so
  # that we can dynamically update using ipv4.tunnelbroker.net/nic/update
  tunnelBrokerClientV4Interface = wanInterface;
  tunnelBrokerTTL = 255;
in

{
  imports = [
    ./hardware-configuration.nix
    ./seedbox.nix
    ./authfish.nix
  ];

  services.authfish.enable = true;

  services.seedbox.enable = true;
  services.seedbox.netNamespaceHostIP = "10.69.44.1";
  services.seedbox.netNamespaceSeedboxIP = "10.69.44.2";
  services.seedbox.wgIps = ["10.66.194.204/32" "fc00:bbbb:bbbb:bb01::3:c2cb/128"];
  services.seedbox.wgListenPort = wgMullvadListenPort;
  services.seedbox.wgPrivateKeyFile = "/etc/secrets/wireguard_mullvad_key";
  services.seedbox.wgPeerPublicKey = "+JJBzQMxFFQ2zu+WN8rbFH4ZpqY2u6WNBGBFHwsxkzs=";
  services.seedbox.wgPeerEndpoint = "142.147.89.240:51820";
  services.seedbox.basicAuthFile = "/etc/secrets/htpasswd";
  services.seedbox.transmissionPeerPort = 59307;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv4.conf.all.forwarding" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  time.timeZone = "America/Los_Angeles";

  networking = {
    hostName = hostName;
    domain = domain;
    useDHCP = false;

    interfaces = {
      # Wan, get IP address from ISP
      "${wanInterface}".useDHCP = true;

      enp3s0.useDHCP = false;
      enp4s0.useDHCP = false;

      "${lanInterface}" = {
        useDHCP = false;
        
        ipv4.addresses = [{
          address = lanV4Address;
          prefixLength = lanV4PrefixLength;
        }];

        ipv6.addresses = [{
          address = lanV6Address;
          prefixLength = lanV6PrefixLength;
        }];
      };

      "${tunnelBrokerInterface}" = {
        ipv6.addresses = [{
          address = tunnelBrokerClientV6;
          prefixLength = 64;
        }];
      };
    };

    defaultGateway6 = {
      address = tunnelBrokerServerV6;
      interface = tunnelBrokerInterface;
      metric = 1;
    };

    sits = {
      "${tunnelBrokerInterface}" = {
        remote = tunnelBrokerServerV4;
        dev = tunnelBrokerClientV4Interface;
        ttl = tunnelBrokerTTL;
      };
    };

    firewall.enable = true;
    firewall.allowedTCPPorts = [ 80 443 ];
    firewall.allowedUDPPorts = [wgListenPort wgMullvadListenPort];
    firewall.interfaces = {
      "${lanInterface}" = {
        allowedUDPPorts = [
          53 # DNS server
          67 # DHCP server
          547 # DHCPv6 ?
          546 # DHCPv6 ?
        ];
      };
    };
    firewall.trustedInterfaces = ["wg0"];

    nat = {
      enable = true;
      externalInterface = wanInterface;
      internalInterfaces = [lanInterface "wg0"];
      internalIPs = [lanV4Cidr wg0V4Cidr];
    };

    wireguard = {
      interfaces = {
        wg0 = {
          ips = [ wg0V6Cidr wg0V4Cidr ];
          listenPort = wgListenPort;
          generatePrivateKeyFile = true;

          # Public key: MxzCIL6xpx/2YjrN7ekWjq3MOJOXmeSzU11cDDNMmFE=
          privateKeyFile = "/etc/secrets/wireguard_key";

          peers = [
            {
              publicKey = "Q/vPUaZxI2pPt6z5V4PgxETswdKJqdT4uomVcfAH4Qg=";
              allowedIPs = [ "10.69.43.2/32" "2001:470:4ac8:2::2/128" ];
            }
          ];
        };
      };
    };
  };

  services.dnsmasq = {
    enable = true;
    # TODO: this used to be true, which set resolv.conf to 127.0.0.1. But once
    # I added transmission in its own network namespace, it was having issues
    # resolving DNS queries. The easy way around this is to not use dnsmasq in
    # resolv.conf, but that isn't particularly elegant.
    resolveLocalQueries = false;
    servers = dnsServers;
    extraConfig = ''
      # Enable DHCP logs
      log-dhcp

      # Uncomment to enable dns logs. They are quite noisy.
      # log-queries

      # never forward queries for plain names, without dots or domain parts, to
      # upstream nameservers
      domain-needed

      # Don't listen on WAN
      except-interface=${wanInterface}

      no-resolv
      no-hosts

      bogus-priv

      local=/lan.${domain}/
      domain=lan.${domain}

      enable-ra
      dhcp-range=::,constructor:${lanInterface},ra-stateless,ra-names

      dhcp-range=${lanV4DhcpStart},${lanV4DhcpEnd},12h
      dhcp-option=option:router,${lanV4Address}

      dhcp-host=${nasMacAddress},${nasIpAddress}

      dhcp-authoritative
    '';
  };

  services.ddclient = {
    enable = true;
    domains = [
      "router.adh.io" 
      "media.adh.io" 

      "jackett.adh.io" 
      "jellyfin.adh.io"
      "lidarr.adh.io"
      "login.adh.io"
      "nzb.adh.io"
      "prowlarr.adh.io"
      "radarr.adh.io" 
      "sonarr.adh.io" 
      "transmission.adh.io"

      "grafana.adh.io"
    ];
    protocol = "Cloudflare";
    zone = "adh.io";
    username = "and.ham95@gmail.com";
    passwordFile = "/etc/secrets/cloudflare.txt";
    interval = "10min";
    use = "if, if=${wanInterface}";
  };

  security.acme.email = "and.ham95@gmail.com";
  security.acme.acceptTerms = true;

  services.nginx = {
    enable = true;
    virtualHosts = {
      "router.adh.io" = {
        forceSSL = true;
        enableACME = true;
        root = "/var/www/router.adh.io";
      };

      "grafana.adh.io" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.grafana.port}";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header   Host               $host;
            proxy_set_header   X-Real-IP          $remote_addr;
            proxy_set_header   X-Forwarded-Proto  $scheme;
            proxy_set_header   X-Forwarded-For    $proxy_add_x_forwarded_for;
          '';
        };

      };
    };
  };

  security.sudo.wheelNeedsPassword = false;
  users.users.andrewhamon = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINNcsvEP/ZAEHTYgqahtTUoWpw18qoo3G4iObCGVwCGq"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIkO+UDBJuvpmTa6EriH1TJdJTx+YB/4uv4LmM+5mOp5"
    ];
  };
  users.users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINNcsvEP/ZAEHTYgqahtTUoWpw18qoo3G4iObCGVwCGq"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIkO+UDBJuvpmTa6EriH1TJdJTx+YB/4uv4LmM+5mOp5"
    ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Update tunnelbroker.net with current IPv4 address
  systemd = {
    timers.tunnel-broker-update = {
      wantedBy = [ "timers.target" ];
      partOf = [ "tunnel-broker-update.service" ];
      timerConfig.OnCalendar = "minutely";
    };
    services.tunnel-broker-update = {
      serviceConfig.Type = "oneshot";
      script = ''
        TUNNELBROKER_UPDATE_KEY=$(<${tunnelBrokerUpdateKeyFile})
        ${pkgs.curl}/bin/curl https://${tunnelBrokerAccountName}:$TUNNELBROKER_UPDATE_KEY@ipv4.tunnelbroker.net/nic/update?hostname=${tunnelBrokerTunnelID}
      '';
    };
  };

  # See https://nixos.org/manual/nixos/stable/options.html#opt-system.stateVersion
  system.stateVersion = "21.11"; # Did you read the comment?


  services.grafana = {
    enable = true;
    domain = "grafana.adh.io";
    port = 2342;
    addr = "127.0.0.1";
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
    };

    scrapeConfigs = [
      {
        job_name = "router_adh_io";
        static_configs = [{
          targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
        }];
      }
    ];
  };
}
