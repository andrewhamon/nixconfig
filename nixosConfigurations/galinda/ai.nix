{ ... }:
{
  services.ollama.enable = true;
  services.ollama.acceleration = "cuda";
  services.open-webui.enable = true;
  services.open-webui.port = 8080;

  # Advertise at galinda.local
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
  };

  services.nginx = {
    enable = true;
    # These subdomains are configured in the Unifi control plane since mDNS
    # doesn't really support subdomains.
    virtualHosts."galinda.local" = {
      locations."/" = {
        proxyPass = "http://localhost:8080";
        proxyWebsockets = true;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
