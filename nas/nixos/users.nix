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

  users.users.taylor = {
    isNormalUser = true;
    group = config.users.groups.media.name;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDaO5EZ9vQjwTuMTPbY+sIZeQsPhAUxJMj6NyCFSkfldrEw7GmZGSeVhB7ymhpSjwugJtCk2JqsZVXB7OF52Lhjr84LEBU/t93OGS6Ngn3jjk0DMFTIAHGQBil/OakyX1bxwmimNBPWk+dxYa23peXb53iUJ3+4uHS52Vy0TshoVP7FN+zzh+kzSp1gwWVTtHTtonCROXzU8++dsAKYTj3PNitG/HaRo9DH6l1DmwCMmL5QfQAkXBMwcFw/47zQ3HomGScChK3HOphVQWsunPTCgqMGCEwKhvmWJLZE/REYvs6IGYn5lzR++CpbZrhWHuRLDdgtmVJxisWzzwpku+xQwvu4/c2trjnC4+6ACVR7k6hHgRyel3S1ZEwCkiVzDoYsy2QdaJbhLcXQO89+1GccfrM7Lquhm4vnw9Sd4tsqGU6KlVSHMZM+rd+I3xLNQ3YFI5agx/kRw++arqSulAh7dWltvEWWjw4reDm30sjOA4Eet9sjcyyYwouU9ACdI5E= Taylor@Desktop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPlM3xZOtpMNUIjZT5/VrJqoz1AdRf6WpPDzJ3pN2Dzj kingpin"

      # Andrews keys, for testing
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINNcsvEP/ZAEHTYgqahtTUoWpw18qoo3G4iObCGVwCGq"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIkO+UDBJuvpmTa6EriH1TJdJTx+YB/4uv4LmM+5mOp5"
    ];
  };
}
