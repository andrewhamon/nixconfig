{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.services.authfish;
  authfishSrc = pkgs.fetchFromGitHub {
    owner = "andrewhamon";
    repo = "authfish";
    rev = "bc4a5e97a8ab555e423e3f7cc611bac5c1c2b05e";
    sha256 = "sha256-plnoYgMkZmtnUf8LjELMa5cFaAmWRKTrL4Q2tobKbM4=";
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

      domains = mkOption {
        type = types.str;
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
        ExecStart = "${authfish}/bin/authfish server --port ${toString cfg.port} --domain ${cfg.domains}";
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
      authfish = { };
    };

    services.nginx.virtualHosts."login.adh.io" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString cfg.port}";
        extraConfig = ''
          proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
        '';
      };
    };
  };
}
