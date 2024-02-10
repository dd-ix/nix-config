{ pkgs, config, ... }: {

  sops.secrets.postgres_vaultwarden.owner = config.services.postgresql.superUser;
  sops.secrets.vaultwarden_env_file.owner = "vaultwarden";

  services = {
    vaultwarden = {
      enable = true;
      dbBackend = "postgresql";
      backupDir = "/var/backup/vaultwarden";
      config = {
        ROCKET_ADDRESS = "::1";
        ROCKET_PORT = 8222;
        DOMAIN = "https://vault.${config.deployment-dd-ix.domain}";
        SIGNUPS_ALLOWED = false;
        WEBSOCKET_ENABLED = true;
        PUSH_ENABLED = false;
        EMAIL_CHANGE_ALLOWED = false;
        # update on demand
        ORG_CREATION_USERS = ""; # none
        PASSWORD_HINTS_ALLOWED = false;
        SMTP_HOST = "mta.dd-ix.net";
        SMTP_PORT = 25;
        SMTP_FROM = "noreply@vault.dd-ix.net";
        SMTP_FROM_NAME = "DD-IX Vault";
        SMTP_SECURITY = "off";
      };
      environmentFile = config.sops.secrets.vaultwarden_env_file.path;
    };

    nginx = {
      enable = true;

      virtualHosts."vault.${config.deployment-dd-ix.domain}" = {
        listen = [{
          addr = "[::]:443";
          proxyProtocol = true;
          ssl = true;
        }];

        onlySSL = true;
        useACMEHost = "vault.${config.deployment-dd-ix.domain}";

        locations =
          let
            upstream = "http://[::1]:${toString config.services.vaultwarden.config.ROCKET_PORT}";
          in
          {
            "/notifications/hub/negotiate" = {
              proxyPass = upstream;
            };
            "/notifications/hub" = {
              proxyPass = upstream;
              proxyWebsockets = true;
            };
            "/".proxyPass = upstream;
          };
      };
    };
  };
}
