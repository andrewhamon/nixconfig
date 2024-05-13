{ ... }:
let
  resume = builtins.fetchTarball {
    url = "https://github.com/andrewhamon/hamon.cc/archive/f4171aef9fecd7f87625c1f1a6fc5e7bc36372aa.tar.gz";
    sha256 = "sha256:1bnjclmk1v3yy83hd76rlsavg5smm1jzr2dnx75g5cdwdrm545ir";
  };
  resumePath = "${resume}";
in
{
  services.nginx.virtualHosts."adh.io" = {
    enableACME = true;
    onlySSL = true;

    root = resumePath;
  };

  services.nginx.virtualHosts.default = {
    locations."/".return = "301 https://$host$request_uri";
    default = true;
    listen = [
      {
        addr = "0.0.0.0";
        port = 80;
        ssl = false;
      }
    ];
  };
}
