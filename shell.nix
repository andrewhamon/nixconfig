{ pkgs, agenixPkg }:
with pkgs;
mkShell {
  buildInputs = [
    agenixPkg
    colmena
    cowsay
  ];
}
