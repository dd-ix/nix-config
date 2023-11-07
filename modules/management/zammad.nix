{ config, pkgs, ... }:
let
  database_name = "zammad";
  username = "zammad";
  http_port = 3000;
  ws_port = 3001;
in
{
  sops.secrets.zammad_db_pass.owner = username;

  services = {
    postgresql = {
      enable = true;
      ensureDatabases = [ database_name ];
      ensureUsers = [
        {
          name = username;
          ensurePermissions = {
            "DATABASE ${database_name}" = "ALL PRIVILEGES";
          };
        }
      ];
    };

    zammad = {
      enable = true;
      package = pkgs.zammad;
      port = http_port;
      websocketPort = ws_port;
      database = {
        type = "PostgreSQL";
        host = "/run/postgresql";
        name = database_name;
        user = username;
        passwordFile = config.sops.secrets.zammad_db_pass.path;
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
              proxyPass = "http://127.0.0.1:${toString config.services.zammad.port.http_port}";
              proxyWebsockets = true;
            };
          };
        };
      }:
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
