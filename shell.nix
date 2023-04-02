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
in
mkShell {
  buildInputs = [
    activate-macos-secrets
    age-plugin-yubikey
    agenixPkg
    colmena
    cowsay
    nixpkgs-fmt
    rage
    rnix-lspPkg
  ];
}
