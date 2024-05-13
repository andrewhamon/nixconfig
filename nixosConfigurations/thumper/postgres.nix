{ ... }:
{
  services.postgresql.enable = true;
  services.postgresql.enableTCPIP = true;
  services.postgresql.ensureDatabases = [
    "andrewhamon"
    "level"
  ];
  services.postgresql.ensureUsers = [
    {
      name = "andrewhamon";
      ensureDBOwnership = true;
      ensureClauses.superuser = true;
    }

    {
      name = "level";
      ensureDBOwnership = true;
      ensureClauses.login = true;
      ensureClauses.createdb = true;
    }
  ];
}
