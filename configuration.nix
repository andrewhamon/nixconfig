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
  lanV4Address = "10.1.1.1";
  lanV4PrefixLength = 24;
  lanV4Cidr = "10.1.1.0/24";
  lanV4DhcpStart = "10.1.1.100";
  lanV4DhcpEnd = "10.1.1.200";

  # "Routed /48" in tunnelbroker.net is 2001:470:4ac8::/48
  # Taking the first /64 for this subnet
  lanV6Address = "2001:470:4ac8:1::1";
  lanV6PrefixLength = 64;

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
  ];

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

    nat = {
      enable = true;
      externalInterface = wanInterface;
      internalInterfaces = [lanInterface];
      internalIPs = [lanV4Cidr];
    };
  };

  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = true;
    servers = dnsServers;
    extraConfig = ''
      # Enable DHCP logs
      log-dhcp

      # Uncomment to enable dns logs. They are quite noisy.
      # log-queries

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

      dhcp-authoritative
    '';
  };

  services.ddclient = {
    enable = true;
    domains = ["router.adh.io"];
    protocol = "Cloudflare";
    zone = "adh.io";
    username = "and.ham95@gmail.com";
    passwordFile = "/etc/secrets/cloudflare.txt";
    interval = "1min";
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
}
