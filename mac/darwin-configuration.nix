{ config, pkgs, ... }:
let
  postgresPkg = pkgs.postgresql_11;
in
{
  users.users.andrewhamon = {
    name = "andrewhamon";
    home = "/Users/andrewhamon";
  };

  environment.shells = [ pkgs.zsh pkgs.bash ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  nix.buildMachines = [{
    hostName = "nas.lan.adh.io";
    systems = [
      "x86_64-linux"
      "i686-linux"
      "aarch64-linux"
    ];
    sshUser = "root";
    sshKey = "/Users/andrewhamon/.ssh/id_ed25519";
    maxJobs = 16;
  }];

  nix.distributedBuilds = true;

  nix.extraOptions = ''
    experimental-features = nix-command flakes
    extra-platforms = x86_64-darwin aarch64-darwin
  '';

  programs.zsh = {
    enable = true;
    promptInit = "";
    enableCompletion = false;
    enableBashCompletion = false;
  };

  programs.bash = {
    enable = true;
  };

  services.postgresql = {
    enable = true;
    package = postgresPkg;
    port = 5432;
    dataDir = "/Users/andrewhamon/.pgdata/${postgresPkg.version}";
    enableTCPIP = true;
    extraPlugins = [ pkgs.postgresql11Packages.postgis ];
  };

  services.redis = {
    enable = true;
    port = 6379;
    bind = "127.0.0.1";
    dataDir = "/Users/andrewhamon/.redisData/";
    extraConfig = ''
      requirepass redis-pwd
    '';
  };

  environment.systemPath = [
    "/Users/andrewhamon/.nix-profile/bin"
    "/run/current-system/sw/bin"
    "/nix/var/nix/profiles/default/bin"
    "/usr/local/bin"
    "/usr/bin"
    "/usr/sbin"
    "/bin"
    "/sbin"
  ];

  environment.etc."sudoers.d/000-sudo-touchid" = {
    text = ''
      Defaults pam_service=sudo-touchid
      Defaults pam_login_service=sudo-touchid
    '';
  };
  environment.etc."pam.d/sudo-touchid" = {
    text = ''
      auth       sufficient     pam_tid.so
      auth       sufficient     pam_smartcard.so
      auth       required       pam_opendirectory.so
      account    required       pam_permit.so
      password   required       pam_deny.so
      session    required       pam_permit.so
    '';
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
