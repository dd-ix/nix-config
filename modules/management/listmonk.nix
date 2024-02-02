{ config, pkgs, ... }:
let
  updateBounceSettings = pkgs.writeShellScriptBin "update-database-config.sh" ''
    ${pkgs.postgresql}/bin/psql \
      -d listmonk \
      -c "UPDATE settings SET value = '$(cat ''${CREDENTIALS_DIRECTORY}/migadu_bounce | tr '\n' ' ' | tr '"' \"'''\")' WHERE key = 'bounce.mailboxes';" 
  '';
in
{
  sops.secrets.listmonk.owner = "netbox";
  sops.secrets.listmonk_bounce_migadu.owner = "netbox";
  sops.secrets.listmonk_postgresql.owner = "postgres";
  systemd.services.listmonk = {
    preStart = ''
      ${pkgs.listmonk}/bin/listmonk --config /nix/store/cjcm9lx15lsqd47ij75gnq4fiwqf4wda-listmonk.toml --idempotent --upgrade --yes
    '';
    serviceConfig = {
      ExecStartPre = [ "${updateBounceSettings}/bin/update-database-config.sh" ];
      LoadCredential = "migadu_bounce:${config.sops.secrets.listmonk_bounce_migadu.path}";
    };
  };
  services = {
    postgresql.ensureUsers = [{ name = "listmonk"; ensurePasswordFile = config.sops.secrets.listmonk_postgresql.path; }];

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
              host = "mta.dd-ix.net";
              port = 25;
              uuid = "3c860444-42f3-425a-8ce7-36aebb7add95";
              tls_type = "none";
              username = "";
              idle_timeout = "15s";
              wait_timeout = "5s";
              auth_protocol = "none";
              email_headers = [ ];
              hello_hostname = "";
              max_msg_retries = 2;
              tls_skip_verify = false;
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
        listen = [{
          addr = "[::]";
          proxyProtocol = true;
          ssl = true;
        }];

        onlySSL = true;
        useACMEHost = "lists.${config.deployment-dd-ix.domain}";

        locations =
          let
            cfg = config.services.listmonk.settings;
          in
          {
            "/".proxyPass = "http://${cfg.app.address}";
          };
      };
    };
  };
}
