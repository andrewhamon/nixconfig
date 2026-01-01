{ pkgs, inputs, root, ... }:
with pkgs;
mkShell {
  buildInputs = [
    age-plugin-yubikey
    cowsay
    deploy-rs
    inputs.nil.packages.${pkgs.system}.default
    nixpkgs-fmt
    opentofu
    rage
    root.packages.agenix
    pkgs.incus.client
  ];
}
