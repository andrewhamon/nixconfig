{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
    ];
  
  services.httpd.enable = true;
  services.httpd.enablePHP = true;

  services.httpd.adminAddr = "and.ham95@gmail.com";
  services.httpd.virtualHosts."jwst.me" = {
    documentRoot = "/home/jwst/jwst.me";
    listen = [
      {
        ip = "127.0.0.1";
        port = 45654;
      }
    ];
    hostName = "jwst.me";
    locations."/" = {
      index = "index.php";
    };
  };

  services.nginx.virtualHosts."jwst.me" = {
    enableACME = true;
    listen = [
        {
          addr = "0.0.0.0";
          port = 443;
          ssl = true;
          extraParameters = ["proxy_protocol"];
        }
      ];
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:45654";
    };
  };
}
