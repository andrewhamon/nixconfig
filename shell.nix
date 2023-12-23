{ pkgs, inputs }:
with pkgs;
let
  agenixPkg = inputs.agenix.defaultPackage.${pkgs.system};
  activate-macos-secrets = writeShellApplication {
    name = "activate-macos-secrets";
    runtimeInputs = [ rage age-plugin-yubikey ];
    text = builtins.readFile ./script/activate-macos-secrets;
  };
  deploy-rs = inputs.deploy-rs.defaultPackage.${pkgs.system};

  # Wrap agenix to point it at the yubikey identity
  agenix = writeShellApplication {
    name = "agenix";
    runtimeInputs = [ rage age-plugin-yubikey ];
    text = ''
      yubikey_identities="$(mktemp)"
      age-plugin-yubikey --identity > "$yubikey_identities"
      "${agenixPkg}/bin/agenix" -i "$yubikey_identities" "$@"
      rm "$yubikey_identities"
    '';
  };
in
mkShell {
  NIXPKGS_ALLOW_UNFREE = "1";
  buildInputs = [
    activate-macos-secrets
    age-plugin-yubikey
    agenix
    cowsay
    deploy-rs
    nixpkgs-fmt
    rage
    inputs.nil.packages.${pkgs.system}.default
  ];
}
  