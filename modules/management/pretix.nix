{ self, config, ... }:

let
  domain = "tickets.${config.dd-ix.domain}";
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
          url = "https://${domain}";
          instance_name = domain;
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
        inherit domain;
      };
    };
    nginx = {
      enable = true;
      virtualHosts = {
        "${domain}" = {
          listen = [{
            addr = "[::]:443";
            proxyProtocol = true;
            ssl = true;
          }];

          onlySSL = true;
          useACMEHost = domain;
        };
      };
    };
  };
}
