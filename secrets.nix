let
  nas = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINTQXeLm3qzah6EyN/16NwiGLvxb5s/PFqQDGdYsyp4S";
  router = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO6BxZP+ryAC8wETOFF0KW0W4id9PsJi9lK6A4fUzWPD";
  allSystems = [ nas router ];

  management = [
    "age1yubikey1q22jrgz9lpsg6qswva505mrl7gk40vv39acc9cfdkwz8ffa7ytsf5qanlrj" # keychain
    "age1yubikey1q0e6wwr0cwnsqvvaazfgkhmt43j44glwzvyygsa7tdmtgp98qczjcdtwmjp" # macbook pro 14
    "age1yubikey1qtpdv5gm6q0hv8xd7x5txqys5j7p579r08q9n2495vxkgj5kc9mm7l6uhdd" # desk yhubikey
  ];
in
{
  "secrets/cloudflare.age".publicKeys = management ++ [ router ];
  "secrets/github_token.age".publicKeys = management;
  "secrets/grafana.age".publicKeys = management ++ [ nas ];
  "secrets/lego_cloudflare_env.age".publicKeys = management ++ [ nas ];
  "secrets/mulvad.age".publicKeys = management ++ [ nas ];

  # Public key is ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG5CE0VhsvrW6vV8oDiwXVfg4CPRjpmBpcvIryhAwA07
  "secrets/nix_remote_builder_id_ed25519.age".publicKeys = management;

  # Public key is ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBNIRHj9XFl+zyNMAP7OCOzBi3DccolUzBQM3i57yBKX
  "secrets/vtt_deploy_id_ed25519.age".publicKeys = management ++ [ nas ];

  "secrets/nas_restic_repository.age".publicKeys = management ++ [ nas ];
  "secrets/nas_restic_password.age".publicKeys = management ++ [ nas ];

  "secrets/id_ed25519_sk_rk_keychain-yubikey.age".publicKeys = management;
}
