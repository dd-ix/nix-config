{ self, config, ... }:

let
  pretix_domain = "events.${config.dd-ix.domain}";
  storefront_domain = "tickets.${config.dd-ix.domain}";

in
{
  sops.secrets."tickets_env" = {
    sopsFile = self + "/secrets/management/tickets.yaml";
    owner = config.services.pretix.user;
  };

  services = {
    pretix = {
      enable = true;
      settings = {
        pretix = {
          url = "https://${pretix_domain}";
          instance_name = pretix_domain;
        };
        database = {
          name = "pretix";
          user = "pretix";
          host = "svc-pg01.dd-ix.net";
          port = 5432;
          backend = "postgresql";
          createLocally = false;
        };
        mail = {
          host = "svc-mta01.dd-ix.net";
          port = 25;
          from = "noreply@tickets.dd-ix.net";
          tls = "on";
        };
      };
      environmentFile = config.sops.secrets.tickets_env.path;
      nginx = {
        enable = true;
        domain = pretix_domain;
      };
    };
    nginx = {
      enable = true;
      virtualHosts = {
        "${pretix_domain}" = {
          listen = [{
            addr = "[::]:443";
            proxyProtocol = true;
            ssl = true;
          }];

          onlySSL = true;
          useACMEHost = pretix_domain;
        };
        "${storefront_domain}" = {
          listen = [{
            addr = "[::]:443";
            proxyProtocol = true;
            ssl = true;
          }];

          onlySSL = true;
          useACMEHost = storefront_domain;
        };
      };
    };
  };
}
