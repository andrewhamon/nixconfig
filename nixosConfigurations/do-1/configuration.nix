{ pkgs, inputs, modulesPath, ... }:
{
  imports = [
    "${toString modulesPath}/virtualisation/digital-ocean-image.nix"
  ];

  networking.firewall.allowedTCPPorts = [ 80 443 8443 17170 ];
  networking.hostName = "login-test";
  networking.domain = "hamcorp.net";

  virtualisation.incus.enable = true;
  virtualisation.incus.ui.enable = true;
  virtualisation.incus.preseed = {
    core = {
      https_address = ":8443";
    };
  };

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "and.ham95@gmail.com";
  security.acme.preliminarySelfsigned = true;
  security.acme.certs."login-test.hamcorp.net" = {
    group = "kanidm";
    listenHTTP = ":80";
  };

  services.lldap.enable = true;
  services.lldap.settings.ldap_host = "0.0.0.0";
  services.lldap.settings.http_host = "0.0.0.0";
  services.lldap.settings.ldap_user_email = "and.ham95@gmail.com";
  services.lldap.settings.ldap_user_pass = "password";
  services.lldap.settings.ldap_base_dn = "dc=hamcorp,dc=net";
  services.lldap.settings.key_seed = "b08ce45d65fa309fead8abb9146ce80a";
  services.lldap.settings.http_url = "https://ldap.hamcorp.net";

  services.kanidm.enableServer = true;
  services.kanidm.serverSettings.tls_chain = "/var/lib/acme/login-test.hamcorp.net/fullchain.pem";
  services.kanidm.serverSettings.tls_key = "/var/lib/acme/login-test.hamcorp.net/key.pem";
  services.kanidm.serverSettings.domain = "login-test.hamcorp.net";
  services.kanidm.serverSettings.origin = "https://login-test.hamcorp.net";
  services.kanidm.serverSettings.bindaddress = "0.0.0.0:443";

  services.kanidm.enableClient = true;
  services.kanidm.clientSettings = {
    uri = "https://login-test.hamcorp.net";
  };

  networking.nftables.enable = true;

  environment.systemPackages = [
    pkgs.incus.client
  ];

  system.stateVersion = "22.05";
}
