{ pkgs, config, lib, ... }: {

  sops.secrets.postgres_vaultwarden.owner = config.services.postgresql.superUser;
  sops.secrets.vaultwarden_env_file.owner = "vaultwarden";

  services = {
    postgresql = {
      enable = true;
      ensureUsers = [
        {
          name = "vaultwarden";
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = [ "vaultwarden" ];
    };
    vaultwarden = {
      enable = true;
      config = {
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;
        DOMAIN = "https://vault.${config.deployment-dd-ix.domain}:443";
        SIGNUPS_ALLOWED = false;
        WEBSOCKET_ENABLED = true;
        PUSH_ENABLED = false;
        EMAIL_CHANGE_ALLOWED = false;
        # update on demand
        ORG_CREATION_USERS = "thomas.liske@dd-ix.net";
        PASSWORD_HINTS_ALLOWED = false;
        SMTP_HOST = "mta.dd-ix.net";
        SMTP_PORT = 25;
        SMTP_FROM = "noreply@vault.dd-ix.net";
        SMTP_FROM_NAME = "DD-IX Vault";
        SMTP_SECURITY = "off";
      };
      dbBackend = "postgresql";
      environmentFile = config.sops.secrets.vaultwarden_env_file.path;
    };

    nginx = {
      enable = true;
      recommendedProxySettings = true;
      # Use recommended settings
      recommendedGzipSettings = true;

      virtualHosts."vault.${config.deployment-dd-ix.domain}" = {
        listen = [{
          addr = "[::]";
          proxyProtocol = true;
          ssl = true;
        }];

        onlySSL = true;
        useACMEHost = "vault.${config.deployment-dd-ix.domain}";

        locations = {
          "/notifications/hub/negotiate" = {
            proxyPass = "http://127.0.0.1:8222";
            proxyWebsockets = true;
          };
          "/notifications/hub" = {
            proxyPass = "http://127.0.0.1:3012";
            proxyWebsockets = true;
          };
          "/".proxyPass = "http://127.0.0.1:8222";
        };
      };
    };
  };
  systemd.services.vaultwarden-pgsetup = {
    description = "Prepare postgres database";
    wantedBy = [ "multi-user.target" ];
    after = [ "networking.target" "postgresql.service" ];
    serviceConfig.Type = "oneshot";

    path = [ pkgs.sudo config.services.postgresql.package ];
    script = ''
      # create postgres user with the specified password
      sudo -u ${config.services.postgresql.superUser} psql -c "ALTER ROLE vaultwarden WITH PASSWORD '$(cat ${config.sops.secrets.postgres_vaultwarden.path})'"
    '';
  };
}
