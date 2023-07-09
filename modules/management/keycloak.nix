{ pkgs, config, lib, ... }:
let
  database_name = "keycloak";
  username = "keycloak";
  http_port = 5000;
in
{

  sops.secrets = {
    postgres_keycloak.owner = config.systemd.services.keycloak.serviceConfig.User;
  };

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

    keycloak = {
      enable = true;
      database = {
        type = "postgresql";
        createLocally = true;
        host = "127.0.0.1";
        port = config.services.postgresql.port;
        name = database_name;
        username = username;
        passwordFile = config.sops.secrets.postgres_keycloak.path;
        useSSL = false;
      };
      settings = {
        proxy = "edge"; # Enables communication through HTTP between the proxy and Keycloak.
        http-port = http_port;
        http-host = "127.0.0.1";
        hostname = "keycloak.${config.deployment-dd-ix.domain}";
      };
    };

    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "keycloak.${config.deployment-dd-ix.domain}" = {
          enableACME = true;
          forceSSL = true;
          locations = {
            "/" = {
              proxyPass = "http://127.0.0.1:${toString config.services.keycloak.settings.http-port}";
              proxyWebsockets = true;
            };
          };
        };
      };
    };
  };
  
  users.groups.keycloak = {};
  users.users.keycloak = {
    isSystemUser = true;
    name = "keycloak";
    extraGroups = [ "keycloak" ];
    group = "keycloak";
  };

  systemd.services.keycloak-pgsetup = {
    description = "Prepare keycloak postgres database";
    wantedBy = [ "multi-user.target" ];
    after = [ "networking.target" "postgresql.service" ];
    serviceConfig.Type = "oneshot";

    path = [ pkgs.sudo config.services.postgresql.package ];
    script = ''
      sudo -u ${config.services.postgresql.superUser} psql -c "ALTER ROLE ${username} WITH PASSWORD '$(cat ${config.sops.secrets.postgres_keycloak.path})'"
    '';
  };
}
