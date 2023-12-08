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
        "project.${config.deployment-dd-ix.domain}" = {
          enableACME = true;
          forceSSL = true;
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
