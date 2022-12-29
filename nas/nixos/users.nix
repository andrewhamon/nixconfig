{ config, lib, pkgs, ... }:

{
  security.sudo.wheelNeedsPassword = false;
  users.users.andrewhamon = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINNcsvEP/ZAEHTYgqahtTUoWpw18qoo3G4iObCGVwCGq"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIkO+UDBJuvpmTa6EriH1TJdJTx+YB/4uv4LmM+5mOp5"
    ];
  };
  users.users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINNcsvEP/ZAEHTYgqahtTUoWpw18qoo3G4iObCGVwCGq"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIkO+UDBJuvpmTa6EriH1TJdJTx+YB/4uv4LmM+5mOp5"
    ];
  
  users.users.jwst = {
    isNormalUser = true;
    homeMode = "755";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMyVXFKM5PhtaIN+vmGjtHLj2X7sxbefSRU68SnLopPK pi@jwst"
    ];
  };
}
