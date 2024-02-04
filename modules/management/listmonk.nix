{ self, lib, config, pkgs, ... }:
let
  updateBounceSettings = pkgs.writeShellScriptBin "update-database-config.sh" ''
    export PGPASSWORD=''${LISTMONK_db__password}
      ${pkgs.postgresql}/bin/psql \
    --host svc-pg01.dd-ix.net \
    --user listmonk \
    -d listmonk \
    -c "UPDATE settings SET value = '$(cat ''${CREDENTIALS_DIRECTORY}/migadu_bounce | tr '\n' ' ' | tr '"' \"'''\")' WHERE key = 'bounce.mailboxes';" 
  '';
in
{
  sops.secrets."lists_env" = {
    sopsFile = self + "/secrets/management/lists.yaml";
  };

  sops.secrets."lists_bounce_migadu" = {
    sopsFile = self + "/secrets/management/lists.yaml";
  };

  systemd.services.listmonk = {
    preStart = ''
      ${pkgs.listmonk}/bin/listmonk --config /nix/store/cjcm9lx15lsqd47ij75gnq4fiwqf4wda-listmonk.toml --idempotent --upgrade --yes
    '';
    serviceConfig = {
      ExecStartPre = [ "${updateBounceSettings}/bin/update-database-config.sh" ];
      LoadCredential = "migadu_bounce:${config.sops.secrets."lists_bounce_migadu".path}";
    };
  };
  services = {
    listmonk = {
      enable = true;
      settings = {
        app.admin_username = "admin";
        db = lib.mkForce {
          host = "svc-pg01.dd-ix.net";
          port = 5432;
          user = "listmonk";
          database = "listmonk";
          ssl_mode = "verify-full";
        };
      };
      secretFile = config.sops.secrets."lists_env".path;
      database = {
        createLocally = false;
        mutableSettings = false;
        settings = {
          smtp = [{
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
          }];
          "privacy.domain_blocklist" = [ ]; # list of domains excluded from subscribing
          "app.notify_emails" = [ "admin@dd-ix.net" ];
        };
      };
    };

    nginx = {
      enable = true;
      virtualHosts."lists.${config.deployment-dd-ix.domain}" = {
        listen = [{
          addr = "[::]:443";
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
