{ config, pkgs, ... }:
let
  database_name = "zammad";
  username = "zammad";
  http_port = 3000;
  ws_port = 3001;
in
{
  sops.secrets.zammad_secret.owner = username;

  services = {
    zammad = {
      enable = true;
      package = pkgs.zammad;
      port = http_port;
      websocketPort = ws_port;
      secretKeyBaseFile = config.sops.secrets.zammad_secret.path;
      database = {
        createLocally = true;
        type = "PostgreSQL";
        name = database_name;
        user = username;
      };
    };

    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "orga.${config.dd-ix.domain}" = {
          listen = [{
            addr = "[::]:443";
            proxyProtocol = true;
            ssl = true;
          }];

          onlySSL = true;
          useACMEHost = "orga.${config.dd-ix.domain}";

          locations = {
            "/" = {
              proxyPass = "http://127.0.0.1:${toString config.services.zammad.port}";
            };
            "/ws" = {
              proxyPass = "http://127.0.0.1:${toString config.services.zammad.websocketPort}";
              proxyWebsockets = true;
            };
          };
        };
      };
    };
  };
}
