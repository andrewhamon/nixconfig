{ pkgs, inputs, ... }:
let
  agenixPkg = inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.agenix;
in
pkgs.writeShellApplication {
  name = "agenix";
  runtimeInputs = with pkgs; [ rage age-plugin-yubikey ];
  text = ''
    yubikey_identities="$(mktemp)"
    age-plugin-yubikey --identity > "$yubikey_identities"
    "${agenixPkg}/bin/agenix" -i "$yubikey_identities" "$@"
    rm "$yubikey_identities"
  '';
}
