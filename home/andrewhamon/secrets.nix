{ config, inputs, ... }:
{
  imports = [
    inputs.homeage.homeManagerModules.homeage
  ];

  homeage = {
    identityPaths = [ "${../../secrets/yubikey-ids.txt}" ];
    installationType = "activation";
    mount = "${config.xdg.configHome}/secrets";

    file."keychain_yubikey_ssh_key" = {
      source = ../../secrets/id_ed25519_sk_rk_keychain-yubikey.age;
    };

    file."desk_yubikey_ssh_key" = {
      source = ../../secrets/id_ed25519_sk_rk_desk-yubikey.age;
    };
  };
}
