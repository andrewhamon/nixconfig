{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.services.vtt;
in
{
  options = {
    services.vtt = {
      enable = mkEnableOption "vtt";

      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/vtt";
        description = "The directory where vtt stores its data files.";
      };

      deployKeyAgeFile = mkOption {
        type = types.path;
      };

      port = mkOption {
        type = types.int;
        default = 3005;
      };

      user = mkOption {
        type = types.str;
        default = "vtt";
      };

      group = mkOption {
        type = types.str;
        default = "vtt";
      };

      virtualHostName = mkOption {
        type = types.str;
      };

      enableACME = mkOption {
        type = types.bool;
      };

      forceSSL = mkOption {
        type = types.bool;
      };

      serviceUserAuthorizedKeys = mkOption {
        type = types.listOf types.str;
        default = [];
      };
    };
  };

  config = mkIf cfg.enable {
    age.secrets.vtt_deploy_key = {
      file = cfg.deployKeyAgeFile;
      path = "/var/lib/vtt/.ssh/id_ed25519";
      mode = "600";
      owner = "vtt";
      group = "vtt";
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' 0775 ${cfg.user} ${cfg.group} - -"
    ];

    systemd.services.vtt = let
      launcher = pkgs.writeShellApplication {
        name = "launch-vtt";
        runtimeInputs = with pkgs; [ nodejs git openssh ];
        text = ''
          export GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

          if [ ! -d "${cfg.dataDir}/src" ]; then
            # Check if a git repo has been cloned to REPO_ROOT, and if not, clone it
              git clone git@github.com:stevenpetryk/vtt-private.git "${cfg.dataDir}/src"
          else
            # Otherwise, pull the latest changes
            pushd ${cfg.dataDir}/src
            git pull
            popd
          fi

          cd ${cfg.dataDir}/src/resources/app/

          node main.js --port=${toString cfg.port} --dataPath=${cfg.dataDir} --proxySSL=true --hostname=${cfg.virtualHostName}
        '';
      };
    in {
      description = "vtt";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${launcher}/bin/launch-vtt";
        Restart = "always";
      };
    };

    users.users = mkIf (cfg.user == "vtt") {
      vtt = {
        isNormalUser = true;
        home = cfg.dataDir;
        group = cfg.group;
        openssh.authorizedKeys.keys = cfg.serviceUserAuthorizedKeys;
      };
    };

    users.groups = mkIf (cfg.group == "vtt") {
      vtt = { };
    };

    services.nginx.virtualHosts = {
      "${cfg.virtualHostName}" = {
        enableACME = cfg.enableACME;
        forceSSL = cfg.forceSSL;
        locations."/" = {
          proxyPass = "http://localhost:${toString cfg.port}";
          proxyWebsockets = true;
        };
      };
    };

    security.sudo.extraRules = [
      {
        users = [ cfg.user ];
        commands = [
          { command = "/run/current-system/sw/bin/systemctl stop vtt"; options = [ "NOPASSWD" ]; }
          { command = "/run/current-system/sw/bin/systemctl start vtt"; options = [ "NOPASSWD" ]; }
          { command = "/run/current-system/sw/bin/systemctl restart vtt"; options = [ "NOPASSWD" ]; }
        ];
      }
    ];
  };
}