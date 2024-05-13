{ root, pkgs, inputs, ... }:
{
  imports = [
    root.nixosModules.enable-flakes
    root.nixosModules.fonts
    inputs.agenix.nixosModules.default
  ];

  environment.systemPackages = with pkgs; [
    ccze
    dig
    ethtool
    git
    htop
    iftop
    iperf
    neofetch
    nmap
    pciutils
    pstree
    restic
    speedtest-cli
    traceroute
    tree
    vim
    wget
    usbutils
    file
    parted
    unzip
    zip
    gzip
    zsh
  ];

  time.timeZone = "America/Los_Angeles";

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "prohibit-password";
  services.openssh.settings.PasswordAuthentication = false;

  services.tailscale.enable = true;

  nix.flakes.enable = true;

  security.sudo.wheelNeedsPassword = false;
  users.users.andrewhamon = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "wireshark" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIE01fGKj9kke6gRQxSBEYWcU1nZcIiWIXUcc4wHPwAhFAAAAFHNzaDprZXljaGFpbi15dWJpa2V5 ssh:keychain-yubikey"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAINriJKggOxnbVT6l73uVAbnFhbfG2h5/zmlafmV5BWbiAAAAFHNzaDo1Qy1OYW5vLTIyNjY0NDkx ssh:5C-Nano-22664491"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIN76Sz97oDbJ+zA7I450zhdXqoYINSVv7cfdZwkJAOLZAAAAEHNzaDpkZXNrLXl1YmlrZXk= ssh:desk-yubikey"
    ];
  };
  users.users.root.openssh.authorizedKeys.keys = [
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIE01fGKj9kke6gRQxSBEYWcU1nZcIiWIXUcc4wHPwAhFAAAAFHNzaDprZXljaGFpbi15dWJpa2V5 ssh:keychain-yubikey"
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAINriJKggOxnbVT6l73uVAbnFhbfG2h5/zmlafmV5BWbiAAAAFHNzaDo1Qy1OYW5vLTIyNjY0NDkx ssh:5C-Nano-22664491"
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIN76Sz97oDbJ+zA7I450zhdXqoYINSVv7cfdZwkJAOLZAAAAEHNzaDpkZXNrLXl1YmlrZXk= ssh:desk-yubikey"
  ];

  users.users.root.hashedPassword = "$y$j9T$Ycl/ECpaJpRKUfzy0ABiO0$pZ3YsIxu4u0BG1bWDCbN532xGYS8mNsBCGl07F0/fW3";
  programs.tmux.enable = true;
}
