{ config, ... }:
{
  sops.secrets.listmonk.owner = "netbox";
  sops.secrets.listmonk_postgresql.owner = "postgresql";

  services = {
    postgresql.ensureUsers.listmonk.ensurePasswordFile = config.sops.secrets.listmonk_postgresql.path;

    listmonk = {
      enable = true;
      settings = {
        app = {
          address = "127.0.0.1:9820";
          admin_username = "admin";
        };
      };
      secretFile = config.sops.secrets.listmonk.path;
      database = {
        createLocally = true;
        mutableSettings = false;
        settings = {
          smtp = [
            {
              enabled = true;
              host = "smtp.migadu.com";
              port = 465;
              tls_type = "TLS";
              idle_timeout = "1s";
              wait_timeout = "1s";
              email_headers = [ ];
            }
          ];
          "privacy.domain_blocklist" = [ ]; # list of domains excluded from subscribing
          "app.notify_emails" = [ "admin@dd-ix.net" ];
        };
      };
    };

    nginx = {
      enable = true;
      virtualHosts."lists.${config.deployment-dd-ix.domain}" = {
        locations =
          let
            cfg = config.services.listmonk.settings;
          in
          {
            "/".proxyPass = "http://${cfg.app.address}";
          };
        forceSSL = true;
        enableACME = true;
      };
    };
  };
}
