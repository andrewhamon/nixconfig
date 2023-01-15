let
  nas = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINTQXeLm3qzah6EyN/16NwiGLvxb5s/PFqQDGdYsyp4S";
  router = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO6BxZP+ryAC8wETOFF0KW0W4id9PsJi9lK6A4fUzWPD";
  gollum = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILknJdrXAUQDxrIi8nETtfKeirAL7b0xXuUNh3Wzu3kU";
  allSystems = [ nas router ];

  andrewhamon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIkO+UDBJuvpmTa6EriH1TJdJTx+YB/4uv4LmM+5mOp5";
  allUsers = [ andrewhamon ];
in
{
  "cloudflare.age".publicKeys = allUsers ++ [ router ];
  "grafana.age".publicKeys = allUsers ++ [ nas ];
  "mulvad.age".publicKeys = allUsers ++ [ nas ];
  "buildkite_api_key.age".publicKeys = allUsers;
  "jupyter_token.age".publicKeys = allUsers;
  "lego_cloudflare_env.age".publicKeys = allUsers ++ [ nas ];
}
