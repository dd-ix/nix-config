{ config, ... }:

let
  domain = "tickets.${config.dd-ix.domain}";
in
{
  services = {
    pretix = {
      enable = true;
      settings = {
        url = "https://${domain}";
        instance_name = domain;
        database = {
          name = "pretix";
          user = "pretix";
          host = "svc-pg01.dd-ix.net:5432";
          backend = "postgresql";
          createLocally = false;
        };
        mail = {
          host = "svc-mta01.dd-ix.net";
          port = 25;
          from = "noreply@tickets.dd-ix.net";
        };
      };
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
