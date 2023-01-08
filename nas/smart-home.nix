{ config, lib, pkgs, modulesPath, inputs, ... }:
let
  protectWithAuthfish = inputs.authfish.lib.protectWithAuthfish;
in
{
  imports =
    [
    ];

  services.zigbee2mqtt.enable = true;
  services.zigbee2mqtt.settings = {
    permit_join = true;
    serial.port = "/dev/ttyUSB0";
    frontend = {
      port = 8081;
      host = "127.0.0.1";
    };
  };

  services.nginx.virtualHosts."z2m.adh.io" =
    let
      uiPort = config.services.zigbee2mqtt.settings.frontend.port;
    in
    protectWithAuthfish config {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString uiPort}";
        proxyWebsockets = true;
      };
    };

  services.mosquitto = {
    enable = true;
    listeners = [{
      acl = [ "pattern readwrite #" ];
      omitPasswordAuth = true;
      settings.allow_anonymous = true;
    }];
  };

  users.users.homebridge = {
    isNormalUser = true;
    group = config.users.groups.homebridge.name;
    uid = 1227;
  };

  users.groups.homebridge = {
    gid = 1226;
  };

  virtualisation.oci-containers.containers.homebridge = {
    image = "oznu/homebridge:latest";
    ports = [ "17878:7878" ];
    volumes = [
      "/var/lib/homebridge:/homebridge"
    ];
    environment = {
      PUID = toString config.users.users.homebridge.uid;
      PGID = toString config.users.groups.homebridge.gid;
      HOMEBRIDGE_CONFIG_UI = toString 1;
      HOMEBRIDGE_CONFIG_UI_PORT = toString 8581;
    };
    extraOptions = [ "--network=host" ];
  };

  services.nginx.virtualHosts."homebridge.adh.io" =
    let
      uiPort = config.virtualisation.oci-containers.containers.homebridge.environment.HOMEBRIDGE_CONFIG_UI_PORT;
    in
    protectWithAuthfish config {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${uiPort}";
        proxyWebsockets = true;
      };
    };

  networking.firewall.allowedTCPPorts = [ 51522 ];
  networking.firewall.allowedUDPPorts = [ 51522 ];
}
