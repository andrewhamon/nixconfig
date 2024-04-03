{ config, pkgs }: {
  enable = true;

  includes = [
    "~/.colima/ssh_config"
  ];

  # Thise are installed from yubikeys using ./script/install-yubikey-ssh-key
  extraConfig = ''
    IdentityFile ~/.ssh/id_ed25519_sk_rk_5C-Nano-22664491
    IdentityFile ${config.homeage.file.desk_yubikey_ssh_key.path}
    IdentityFile ${config.homeage.file.keychain_yubikey_ssh_key.path}
  '';
}
