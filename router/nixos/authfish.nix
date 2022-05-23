{ lib, pkgs, config, ... }:
with lib;                      
let
  cfg = config.services.authfish;
  authfishSrc = pkgs.fetchFromGitHub {
    owner  = "andrewhamon";
    repo   = "authfish";
    rev    = "34e38e97ab04d10b11b622213f34b66c34dca6fb";
    sha256 = "sha256:0v72ir1mljdvrhz7g8y1nga5m4454hvsk7mx9l93kirpdr11vr7a";
  };
  authfish = import "${authfishSrc}/default.nix" { pkgs = pkgs; };
in
{
  options = {
    services.authfish = {
      enable = mkEnableOption "Authfish";

      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/authfish/";
        description = "The directory where Authfish stores its data files.";
      };

      port = mkOption {
        type = types.int;
        default = 8478;
      };

      user = mkOption {
        type = types.str;
        default = "authfish";
      };

      group = mkOption {
        type = types.str;
        default = "authfish";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      authfish
    ];

    systemd.services.authfish = {
      description = "Authfish";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${authfish}/bin/authfish server --port ${toString cfg.port}";
        Restart = "on-failure";
      };
    };

    users.users = mkIf (cfg.user == "authfish") {
      authfish = {
        isNormalUser = true;
        home = cfg.dataDir;
        group = cfg.group;
      };
    };

    users.groups = mkIf (cfg.group == "authfish") {
      authfish = {};
    };

    services.nginx.virtualHosts."login.adh.io" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString cfg.port}";
      };
    };
  };
}
