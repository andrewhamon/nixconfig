{ pkgs, inputs }:
with pkgs;
let
  agenixPkg = inputs.agenix.defaultPackage.${pkgs.system};
  rnix-lspPkg = inputs.rnix-lsp.defaultPackage.${pkgs.system};
  activate-macos-secrets = writeShellApplication {
    name = "activate-macos-secrets";
    runtimeInputs = [ rage age-plugin-yubikey ];
    text = builtins.readFile ./script/activate-macos-secrets;
  };

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
  buildInputs = [
    activate-macos-secrets
    age-plugin-yubikey
    agenix
    colmena
    cowsay
    nixpkgs-fmt
    rage
    rnix-lspPkg
  ];
}
