{ pkgs, inputs }:
with pkgs;
let
  agenixPkg = inputs.agenix.defaultPackage.${pkgs.system};
  rnix-lspPkg = inputs.rnix-lsp.defaultPackage.${pkgs.system};
in
mkShell {
  buildInputs = [
    agenixPkg
    colmena
    cowsay
    nixpkgs-fmt
    rnix-lspPkg
  ];
}
