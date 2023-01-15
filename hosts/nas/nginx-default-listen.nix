{ lib, ... }:
with lib;
{
  # nas owns all the virtual hosts, but its actually behind NAT so can't
  # actually listen on a public IP. At the same time, port forwarding 80 and 443
  # to nas from router seems to have issues (doesn't port forward internal
  # connections). So instead of port forwarding, router is running haproxy. To
  # continue being able to get real IPs, we need to use proxy_protocol instead
  # of raw TCP.
  #
  # This config changes the default listen in the nginx module to listen with
  # proxy_protocol.
  options.services.nginx.virtualHosts = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      config.listen = lib.mkDefault [
        {
          addr = "0.0.0.0";
          port = 443;
          ssl = true;
          extraParameters = [ "proxy_protocol" ];
        }
      ];

      config.acmeRoot = lib.mkDefault null;
    });
  };
}
