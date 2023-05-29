{ lib, pkgs, config, inputs, ... }:{
  age.secrets.nas_restic_repository.file = ../../secrets/nas_restic_repository.age;
  age.secrets.nas_restic_password.file = ../../secrets/nas_restic_password.age;

  services.restic.backups.nas = {
    initialize = true;
    repositoryFile = config.age.secrets.nas_restic_repository.path;
    passwordFile = config.age.secrets.nas_restic_password.path;
    timerConfig = {
      OnCalendar="*-*-* 4:00:00";
    };
    paths = [
      "/home"
      "/var/lib"
    ];
    extraBackupArgs = [
      "--exclude-caches"
      "--exclude=/var/lib/containers/"
      "--exclude=/var/lib/docker/"
      "--exclude=/var/lib/prometheus2/"
      "--exclude=/var/lib/transmission/Downloads/"
      "--exclude=/var/lib/transmission/.incomplete/"
      "--exclude=/home/media/downloads/"
    ];
  };
}