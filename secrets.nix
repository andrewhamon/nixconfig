let
  nas = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINTQXeLm3qzah6EyN/16NwiGLvxb5s/PFqQDGdYsyp4S";
  router = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO6BxZP+ryAC8wETOFF0KW0W4id9PsJi9lK6A4fUzWPD";
  gollum = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILknJdrXAUQDxrIi8nETtfKeirAL7b0xXuUNh3Wzu3kU";
  yubikey = "age1yubikey1q22jrgz9lpsg6qswva505mrl7gk40vv39acc9cfdkwz8ffa7ytsf5qanlrj";
  allSystems = [ nas router ];

  andrewhamon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIkO+UDBJuvpmTa6EriH1TJdJTx+YB/4uv4LmM+5mOp5";
  allUsers = [ andrewhamon yubikey ];
in
{
  "secrets/buildkite_api_key.age".publicKeys = allUsers;
  "secrets/cloudflare.age".publicKeys = allUsers ++ [ router ];
  "secrets/grafana.age".publicKeys = allUsers ++ [ nas ];
  "secrets/jupyter_token.age".publicKeys = allUsers;
  "secrets/lego_cloudflare_env.age".publicKeys = allUsers ++ [ nas ];
  "secrets/mulvad.age".publicKeys = allUsers ++ [ nas ];
}
