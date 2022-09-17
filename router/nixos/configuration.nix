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
  nasMacAddress = "a8:a1:59:c6:68:aa";
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
      };

    };

    firewall.enable = true;
    firewall.allowedTCPPorts = [ 80 443 ];
    firewall.interfaces = {
      "${lanInterface}" = {
        allowedUDPPorts = [
          53 # DNS server
          67 # DHCP server
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
      "radarr1080.adh.io"
      "sonarr.adh.io"
      "sonarr1080.adh.io"
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

  services.haproxy = {
    enable = true;
    config = ''
      defaults
        mode tcp

      frontend all_http
        bind :80
        default_backend nas_http

      frontend all_https
        bind :443
        default_backend nas_https
    
      backend nas_http
        server s1 ${nasIpAddress}:80

      backend nas_https
        server s1 ${nasIpAddress}:443 send-proxy-v2
    '';
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

  # See https://nixos.org/manual/nixos/stable/options.html#opt-system.stateVersion
  system.stateVersion = "21.11"; # Did you read the comment?
}
