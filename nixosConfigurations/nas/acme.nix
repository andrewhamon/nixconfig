{ config, ... }: {
  security.acme.defaults.email = "and.ham95@gmail.com";
  security.acme.acceptTerms = true;
  security.acme.defaults.dnsProvider = "cloudflare";

  age.secrets.lego_cloudflare_env.file = ../../secrets/lego_cloudflare_env.age;

  security.acme.defaults.credentialsFile = config.age.secrets.lego_cloudflare_env.path;
}
