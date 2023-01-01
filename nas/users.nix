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
}
