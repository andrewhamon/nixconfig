let
  nas = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINTQXeLm3qzah6EyN/16NwiGLvxb5s/PFqQDGdYsyp4S";
  router = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO6BxZP+ryAC8wETOFF0KW0W4id9PsJi9lK6A4fUzWPD";
  gollum = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILknJdrXAUQDxrIi8nETtfKeirAL7b0xXuUNh3Wzu3kU";
  allSystems = [ nas router ];

  management = [
    "age1yubikey1q22jrgz9lpsg6qswva505mrl7gk40vv39acc9cfdkwz8ffa7ytsf5qanlrj"
    "age1yubikey1q0e6wwr0cwnsqvvaazfgkhmt43j44glwzvyygsa7tdmtgp98qczjcdtwmjp"
  ];
in
{
  "secrets/buildkite_api_key.age".publicKeys = management;
  "secrets/cloudflare.age".publicKeys = management ++ [ router ];
  "secrets/github_token.age".publicKeys = management;
  "secrets/grafana.age".publicKeys = management ++ [ nas ];
  "secrets/jupyter_token.age".publicKeys = management;
  "secrets/lego_cloudflare_env.age".publicKeys = management ++ [ nas ];
  "secrets/mulvad.age".publicKeys = management ++ [ nas ];

  # Public key is ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG5CE0VhsvrW6vV8oDiwXVfg4CPRjpmBpcvIryhAwA07
  "secrets/nix_remote_builder_id_ed25519.age".publicKeys = management;

  # Public key is ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBNIRHj9XFl+zyNMAP7OCOzBi3DccolUzBQM3i57yBKX
  "secrets/vtt_deploy_id_ed25519.age".publicKeys = management ++ [ nas ];

  "secrets/nas_restic_repository.age".publicKeys = management ++ [ nas ];
  "secrets/nas_restic_password.age".publicKeys = management ++ [ nas ];
}