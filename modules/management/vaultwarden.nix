{ pkgs, config, lib, ... }: {

  sops.secrets.postgres_vaultwarden.owner = config.services.postgresql.superUser;

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
        DOMAIN = "https://vaultwarden.dd-ix.net";
        SIGNUPS_ALLOWED = false;
      };
      dbBackend = "postgresql";
      environmentFile = /var/lib/vaultwarden.env;
    };

    nginx = {
      enable = true;
      recommendedProxySettings = true;
      # Use recommended settings
      recommendedGzipSettings = true;

      virtualHosts."vautwarden.dd-ix.net" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8222";
          proxyWebsockets = true;
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
      sudo -u ${config.services.postgresql.superUser} psql -c "ALTER ROLE vaultwarden WITH PASSWORD '$(cat ${config.sops.secrets.postgres_vaultwarden.path})"
    '';
  };
}
