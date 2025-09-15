{ config, pkgs }: {
  enable = true;

  includes = [
    "~/.colima/ssh_config"
  ];

  matchBlocks = {
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
