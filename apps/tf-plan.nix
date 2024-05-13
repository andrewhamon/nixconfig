{ pkgs, root, ... }:
let
  program = pkgs.writers.writeBash "tf-plan" ''
    export PROXMOX_VE_API_TOKEN="$(${root.packages.agenix}/bin/agenix -d secrets/proxmox_api_token.age)"
    if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
    cp ${root.terraform.json} config.tf.json \
      && ${pkgs.opentofu}/bin/tofu init \
      && ${pkgs.opentofu}/bin/tofu plan -out tf_plan
  '';
in
{
  type = "app";
  program = "${program}";
}
