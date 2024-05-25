{ self, config, ... }: {

  sops.secrets."vault_env" = {
    sopsFile = self + "/secrets/management/vault.yaml";
    owner = config.systemd.services.vaultwarden.serviceConfig.User;
  };

  services = {
    vaultwarden = {
      enable = true;
      dbBackend = "postgresql";
      config = {
        ROCKET_ADDRESS = "::1";
        ROCKET_PORT = 8222;
        DOMAIN = "https://vault.${config.dd-ix.domain}";
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
      environmentFile = config.sops.secrets.vault_env.path;
    };

    nginx = {
      enable = true;

      virtualHosts."vault.${config.dd-ix.domain}" = {
        listen = [{
          addr = "[::]:443";
          proxyProtocol = true;
          ssl = true;
        }];

        onlySSL = true;
        useACMEHost = "vault.${config.dd-ix.domain}";

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
