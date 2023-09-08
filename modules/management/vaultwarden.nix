{ pkgs, config, lib, ... }: {

  sops.secrets.postgres_vaultwarden.owner = config.services.postgresql.superUser;
  sops.secrets.vaultwarden_env_file.owner = "vaultwarden";

  services = {
    postgresql = {
      enable = true;
      ensureUsers = [
        {
          name = "vaultwarden";
          ensurePermissions = {
            "DATABASE vaultwarden" = "ALL PRIVILEGES";
          };
        }
      ];
      ensureDatabases = [ "vaultwarden" ];
    };
    vaultwarden = {
      enable = true;
      config = {
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;
        DOMAIN = "https://vaultwarden.dd-ix.net:443";
        SIGNUPS_ALLOWED = false;
	WEBSOCKET_ENABLED=true;
	SMTP_HOST="smtp.migadu.com";
  	SMTP_FROM="vaultwarden@dd-ix.net";
  	SMTP_PORT=587;
  	SMTP_SECURITY="starttls";
  	SMTP_USERNAME="vaultwarden@dd-ix.net";
      };
      dbBackend = "postgresql";
      environmentFile = config.sops.secrets.vaultwarden_env_file.path;
    };

    nginx = {
      enable = true;
      recommendedProxySettings = true;
      # Use recommended settings
      recommendedGzipSettings = true;

      virtualHosts."vaultwarden.dd-ix.net" = {
       http2 = true;
       forceSSL = true;
       enableACME = true;
       #root = "/srv/www/vault.lissner.net";
       extraConfig = ''
          client_max_body_size 64M;
          # if ($deny) { return 503; }
       '';
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
