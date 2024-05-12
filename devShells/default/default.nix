{ pkgs, inputs, root, ... }:
with pkgs;
mkShell {
  NIXPKGS_ALLOW_UNFREE = "1";
  buildInputs = [
    age-plugin-yubikey
    cowsay
    deploy-rs
    inputs.deploy-rs.defaultPackage.${pkgs.system}
    inputs.nil.packages.${pkgs.system}.default
    nixpkgs-fmt
    opentofu
    rage
    root.packages.agenix
  ];
}
