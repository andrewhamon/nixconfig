{ pkgs, agenixPkg, rnix-lspPkg }:
with pkgs;
mkShell {
  buildInputs = [
    agenixPkg
    colmena
    cowsay
    nixpkgs-fmt
    rnix-lspPkg
  ];
}
