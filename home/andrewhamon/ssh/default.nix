{ config, pkgs }:
let
  onePasswordAgentSocket =
    if pkgs.stdenv.isDarwin
    then "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    else "~/.1password/agent.sock";
in
{
  enable = true;

  includes = [
    "~/.colima/ssh_config"
  ];

  matchBlocks = {
    "*" = {
      extraOptions = {
        IdentityAgent = ''"${onePasswordAgentSocket}"'';
      };
    };

    "gerrit.lix.systems" = {
      user = "andrewhamon";
      port = 2022;
      extraOptions = {
        ControlMaster = "auto";
        ControlPath = "/tmp/ssh-%r@%h:%p";
        ControlPersist = "120";
      };
    };
  };
}
