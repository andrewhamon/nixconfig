{ pkgs, lib, config, inputs, ... }:
let
  dumpYubikeyIds = pkgs.writeShellApplication {
    name = "dumpYubikeyIds";
    runtimeInputs = with pkgs; [ rage age-plugin-yubikey ];
    text = ''
      yubikey_identities=/tmp/current-yubikey-identities
      age-plugin-yubikey --identity > "$yubikey_identities"
    '';
  };
in
{
  imports = [
    inputs.homeage.homeManagerModules.homeage
  ];

  homeage = {
    pkg = pkgs.writeShellApplication {
      name = "age";
      runtimeInputs = with pkgs; [ age age-plugin-yubikey ];
      text = ''
        age "$@"
      '';
    };
    identityPaths = [ "/tmp/current-yubikey-identities" ];
    installationType = "activation";
    mount = "${config.xdg.configHome}/secrets";

    file.keychain_yubikey_ssh_key = {
      source = ../../secrets/id_ed25519_sk_rk_keychain-yubikey.age;
    };

    file.desk_yubikey_ssh_key = {
      source = ../../secrets/id_ed25519_sk_rk_desk-yubikey.age;
    };

    file.discord_desk_yubikey_ssh_key = {
      source = ../../secrets/id_ed25519_sk_rk_discord-desk.age;
    };
  };

  # homage cleanup is currently broken
  home.activation.homeageCleanup = lib.mkForce (lib.hm.dag.entryAfter [ "writeBoundary" ] '''');


  home.activation.dumpYubikeys = lib.mkForce (lib.hm.dag.entryBefore [ "writeBoundary" ] ''
    ${dumpYubikeyIds}/bin/dumpYubikeyIds
  '');
}
