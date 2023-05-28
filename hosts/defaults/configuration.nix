{ config, pkgs, inputs, ... }:
{
  imports = [
    inputs.agenix.nixosModule
  ];

  environment.systemPackages = with pkgs; [
    dig
    git
    htop
    iftop
    iperf
    nmap
    pciutils
    ethtool
    pstree
    speedtest-cli
    traceroute
    tree
    vim
    wget
  ];

  time.timeZone = "America/Los_Angeles";

  services.openssh.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  security.sudo.wheelNeedsPassword = false;
  users.users.andrewhamon = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINNcsvEP/ZAEHTYgqahtTUoWpw18qoo3G4iObCGVwCGq"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIkO+UDBJuvpmTa6EriH1TJdJTx+YB/4uv4LmM+5mOp5"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIE01fGKj9kke6gRQxSBEYWcU1nZcIiWIXUcc4wHPwAhFAAAAFHNzaDprZXljaGFpbi15dWJpa2V5 ssh:keychain-yubikey"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAINriJKggOxnbVT6l73uVAbnFhbfG2h5/zmlafmV5BWbiAAAAFHNzaDo1Qy1OYW5vLTIyNjY0NDkx ssh:5C-Nano-22664491"
    ];
  };
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINNcsvEP/ZAEHTYgqahtTUoWpw18qoo3G4iObCGVwCGq"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIkO+UDBJuvpmTa6EriH1TJdJTx+YB/4uv4LmM+5mOp5"
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIE01fGKj9kke6gRQxSBEYWcU1nZcIiWIXUcc4wHPwAhFAAAAFHNzaDprZXljaGFpbi15dWJpa2V5 ssh:keychain-yubikey"
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAINriJKggOxnbVT6l73uVAbnFhbfG2h5/zmlafmV5BWbiAAAAFHNzaDo1Qy1OYW5vLTIyNjY0NDkx ssh:5C-Nano-22664491"
  ];

  programs.tmux.enable = true;
}
