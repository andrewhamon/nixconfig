{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.namespaced-wg;
in
{
  options.services.namespaced-wg = {
    enable = mkEnableOption "Namespaced Wireguard";

    # Name should be relatively short. It is used for interface names, which
    # seem to break if they exceed 15 characters.
    name = mkOption {
      type = types.str;
    };
    ips = mkOption {
      type = types.listOf types.str;
    };
    peerPublicKey = mkOption {
      type = types.str;
    };
    peerEndpoint = mkOption {
      type = types.str;
    };
    peerAllowedIps = mkOption {
      type = types.listOf types.str;
      default = [ "0.0.0.0/0" "::/0" ];
    };
    privateKeyFile = mkOption {
      type = types.str;
    };
    guestPortalIp = mkOption {
      type = types.str;
    };
    hostPortalIp = mkOption {
      type = types.str;
    };

    # This isn't exactly config, but I couldn't think of a better way to easily
    # let us reference this attrset elsewhere. This is used to mod the systemd
    # config of any existing service. These changes will cause the services to
    # come up in the network namespace
    systemdMods = mkOption {
      type = types.anything;
      default = {
        after = ["network.target" "netns_${config.services.namespaced-wg.name}.service"];
        bindsTo = ["netns_${config.services.namespaced-wg.name}.service"];
        partOf = ["netns_${config.services.namespaced-wg.name}.service"];
        serviceConfig.NetworkNamespacePath = "/var/run/netns/${config.services.namespaced-wg.name}";
      };
    };
  };
  config = mkIf cfg.enable {
    networking.wireguard.interfaces."${cfg.name}" = {
      ips = cfg.ips;
      privateKeyFile = cfg.privateKeyFile;
      interfaceNamespace = cfg.name;
      peers = [
        {
          publicKey = cfg.peerPublicKey;
          allowedIPs = cfg.peerAllowedIps;
          endpoint = cfg.peerEndpoint;
        }
      ];
    };

    # Modify the wireguard systemd service (implicitly defined using the wireguard
    # module above) to wait for the netns_${cfg.name} service (defined below)
    # to be active. This ensures that the network namespace has already been set
    # up before creating the wireguard interface.
    systemd.services."wireguard-${cfg.name}" = {
      after = ["network.target" "network-online.target" "netns_${cfg.name}.service"];
      bindsTo = ["netns_${cfg.name}.service"];
      partOf = ["netns_${cfg.name}.service"];
    };

    # Create a systemd service that does the following:
    #  - creates a new netowrk namespace
    #  - creates an pair of veth interfaces and IP addresses that allow
    #    communication with processes inside the namespace. This is essential to
    #    be able to view UIs and such. Only very specific IP routes are added,
    #    these IPs and interfaces will not enable any communication beyond the
    #    host.
    #
    # The naming convention is that on the host outside of any network
    # namespace, there is an interface named ${cfg.name}_portal. This connects
    # directly to an interface that is moved inside of the network namespace,
    # named "${cfg.name}_hportal". Software running inside the namesapce can
    # bind to ${cfg.name}_hportal (or 0.0.0.0 to bind to all interfaces) and
    # become accessible from outside the namespace only through the
    # ${cfg.name}_portal interface.
    systemd.services."netns_${cfg.name}" = {
      description = "${cfg.name} network namespace";
      before = [ "network.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStop = "ip netns del ${cfg.name}";
      };
      script = ''
          ipCmd="${pkgs.iproute}/bin/ip"
          set -x

          # Delete the ns if it already exists. Mostly handy for developemt, in
          # case this setup fails partway through and leaves things in an odd
          # state.
          ($ipCmd netns list | grep ${cfg.name}) && $ipCmd netns delete ${cfg.name}

          $ipCmd netns add ${cfg.name}

          # It seems like netns delete doesn't immediately clean up all the
          # related resources. If we are too fast, recreating interfaces with
          # the same name will fail. RIP.
          sleep 3

          $ipCmd link add ${cfg.name}_portal type veth peer ${cfg.name}_hportal
          $ipCmd link set dev ${cfg.name}_hportal netns ${cfg.name}

          $ipCmd addr add ${cfg.hostPortalIp}/32 dev ${cfg.name}_portal
          $ipCmd netns exec ${cfg.name} $ipCmd addr add ${cfg.guestPortalIp}/32 dev ${cfg.name}_hportal

          $ipCmd link set dev ${cfg.name}_portal up
          $ipCmd route add ${cfg.guestPortalIp}/32 dev ${cfg.name}_portal

          $ipCmd netns exec ${cfg.name} $ipCmd link set dev ${cfg.name}_hportal up
          $ipCmd netns exec ${cfg.name} $ipCmd route add ${cfg.hostPortalIp}/32 dev ${cfg.name}_hportal
        '';
    };
  };
}
