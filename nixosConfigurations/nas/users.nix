{ config, lib, pkgs, ... }:

{
  users.users.jwst = {
    isNormalUser = true;
    homeMode = "755";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMyVXFKM5PhtaIN+vmGjtHLj2X7sxbefSRU68SnLopPK pi@jwst"
    ];
    packages = [
      pkgs.imagemagick
    ];
  };

  users.users.remotebuilder = {
    isNormalUser = true;
    # Public key for secrets/nix_remote_builder_id_ed25519.age
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG5CE0VhsvrW6vV8oDiwXVfg4CPRjpmBpcvIryhAwA07"
    ];
  };
}
