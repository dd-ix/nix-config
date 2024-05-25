{ self, lib, config, pkgs, inputs, ... }:
let
  cfg = config.services.listmonk;
  tomlFormat = pkgs.formats.toml { };
  cfgFile = tomlFormat.generate "listmonk.toml" cfg.settings;
  setDatabaseOption = key: value:
    "UPDATE settings SET value = '${
      lib.replaceStrings [ "'" ] [ "''" ] (builtins.toJSON value)
    }' WHERE key = '${key}';";
  updateDatabaseConfigSQL = pkgs.writeText "update-database-config.sql"
    (lib.concatStringsSep "\n" (lib.mapAttrsToList setDatabaseOption
      (if (cfg.database.settings2 != null) then
        cfg.database.settings2
      else
        { })));

  updateBounceSettings = pkgs.writeShellScriptBin "update-database-config.sh" ''
    export PGPASSWORD=''${LISTMONK_db__password}
    "${pkgs.postgresql}/bin/psql" \
      --host svc-pg01.dd-ix.net \
      --port 5432 \
      --username listmonk \
      --dbname listmonk \
      -f "${updateDatabaseConfigSQL}"
      
    "${pkgs.postgresql}/bin/psql" \
      --host svc-pg01.dd-ix.net \
      --port 5432 \
      --username listmonk \
      --dbname listmonk \
      --command "UPDATE settings SET value = '$(cat ''${CREDENTIALS_DIRECTORY}/migadu_bounce | tr '\n' ' ' | tr '"' \"'''\")' WHERE key = 'bounce.mailboxes';" 
  '';
in
{
  options = {
    services.listmonk.database.settings2 = lib.mkOption {
      default = null;
      type = with lib.types; let
        valueType = nullOr
          (oneOf [
            bool
            int
            float
            str
            path
            (attrsOf valueType)
            (listOf valueType)
          ]) // {
          description = "listmonk value";
        };
      in
      valueType;
      description = lib.mdDoc
        "Dynamic settings in the PostgreSQL database, set by a SQL script, see <https://github.com/knadh/listmonk/blob/master/schema.sql#L177-L230> for details.";
    };
  };
  config = {
    sops.secrets."lists_env" = {
      sopsFile = self + "/secrets/management/lists.yaml";
    };

    sops.secrets."lists_bounce_migadu" = {
      sopsFile = self + "/secrets/management/lists.yaml";
    };

    systemd.services.listmonk = {
      serviceConfig = {
        ExecStartPre = lib.mkForce [
          ''${pkgs.coreutils}/bin/mkdir -p "''${STATE_DIRECTORY}/listmonk/uploads"''
          "${cfg.package}/bin/listmonk --config ${cfgFile} --idempotent --install --yes"
          "${cfg.package}/bin/listmonk --config ${cfgFile} --upgrade --yes"
          "${updateBounceSettings}/bin/update-database-config.sh"
        ];
        LoadCredential = "migadu_bounce:${config.sops.secrets."lists_bounce_migadu".path}";
      };
    };
    services = {
      listmonk = {
        enable = true;
        package = inputs.nixpkgs-listmonk.legacyPackages.x86_64-linux.listmonk;
        settings = {
          app.admin_username = "admin";
          db = {
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
          settings2 = {
            "app.site_name" = "DD-IX Mailing";
            "app.root_url" = "https://lists.dd-ix.net";
            "app.logo_url" = "https://dd-ix.net/en/assets/images/logo.png";
            "app.favicon_url" = "https://dd-ix.net/en/favicon.ico";
            "app.from_email" = "DD-IX Mailing <noreply@lists.dd-ix.net>";
            "privacy.domain_blocklist" = [ ]; # list of domains excluded from subscribing
            "app.notify_emails" = [ "noc@dd-ix.net" ];
            "bounce.enabled" = true;
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
              max_conns = 1;

            }];
          };
        };
      };
      nginx = {
        enable = true;
        virtualHosts."lists.${config.dd-ix.domain}" = {
          listen = [{
            addr = "[::]:443";
            proxyProtocol = true;
            ssl = true;
          }];

          onlySSL = true;
          useACMEHost = "lists.${config.dd-ix.domain}";

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
  };
}
