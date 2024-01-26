{ config, pkgs }: {
  enable = true;

  package = pkgs.openssh;

  includes = [
    "~/.colima/ssh_config"
  ];

  # Thise are installed from yubikeys using ./script/install-yubikey-ssh-key
  extraConfig = ''
    IdentityFile ~/.ssh/id_ed25519_sk_rk_5C-Nano-22664491
    IdentityFile ${config.homeage.file.keychain_yubikey_ssh_key.path}
    IdentityFile ~/.ssh/id_ed25519_sk_rk_desk-yubikey
  '';

  # Keep SSH sessions open for two minutes to reduce the amount of interaction
  # required for repeated ssh/git operations.
  controlMaster = "auto";
  controlPersist = "2m";
}
