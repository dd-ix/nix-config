{ self, config, pkgs, lib, nixpkgs-onlyoffice, ... }:
let
  domain = "cloud.${config.deployment-dd-ix.domain}";
  cfg = config.services.onlyoffice;
in
{
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "corefonts"
  ];

  sops.secrets."cloud_admin_pw" = {
    sopsFile = self + "/secrets/management/cloud.yaml";
    owner = config.systemd.services.nextcloud-setup.serviceConfig.User;
  };

  sops.secrets."cloud_db_pw" = {
    sopsFile = self + "/secrets/management/cloud.yaml";
    owner = config.systemd.services.nextcloud-setup.serviceConfig.User;
  };

  sops.secrets."office_db_pw" = {
    sopsFile = self + "/secrets/management/cloud.yaml";
    owner = config.systemd.services.onlyoffice-docservice.serviceConfig.User;
  };

  sops.secrets."office_jwt_secret" = {
    sopsFile = self + "/secrets/management/cloud.yaml";
    owner = config.systemd.services.onlyoffice-docservice.serviceConfig.User;
  };

  systemd.services = {
    nextcloud-setup.after = [ "network.target" ];
    onlyoffice-converter = {
      after = lib.mkForce [ "network.target" "onlyoffice-docservice.service" ];
      requires = lib.mkForce [ "network.target" "onlyoffice-docservice.service" ];
    };
    onlyoffice-docservice = {
      after = [ "network.target" ];
      requires = lib.mkForce [ ];
      serviceConfig.ExecStartPre = lib.mkForce [
        (pkgs.writeShellScript
          "onlyoffice-prestart"
          ''
            PATH=$PATH:${lib.makeBinPath (with pkgs; [ jq moreutils config.services.postgresql.package ])}
            umask 077
            mkdir -p /run/onlyoffice/config/ /var/lib/onlyoffice/documentserver/sdkjs/{slide/themes,common}/ /var/lib/onlyoffice/documentserver/{fonts,server/FileConverter/bin}/
            cp -r ${cfg.package}/etc/onlyoffice/documentserver/* /run/onlyoffice/config/
            chmod u+w /run/onlyoffice/config/default.json

            # Allow members of the onlyoffice group to serve files under /var/lib/onlyoffice/documentserver/App_Data
            chmod g+x /var/lib/onlyoffice/documentserver

            cp /run/onlyoffice/config/default.json{,.orig}

            # for a mapping of environment variables from the docker container to json options see
            # https://github.com/ONLYOFFICE/Docker-DocumentServer/blob/master/run-document-server.sh
            jq '
              .services.CoAuthoring.server.port = ${toString cfg.port} |
              .services.CoAuthoring.sql.dbHost = "${cfg.postgresHost}" |
              .services.CoAuthoring.sql.dbName = "${cfg.postgresName}" |
            ${lib.optionalString (cfg.postgresPasswordFile != null) ''
              .services.CoAuthoring.sql.dbPass = "'"$(cat ${cfg.postgresPasswordFile})"'" |
            ''}
              .services.CoAuthoring.sql.dbUser = "${cfg.postgresUser}" |
            ${lib.optionalString (cfg.jwtSecretFile != null) ''
              .services.CoAuthoring.sql.pgPoolExtraOptions.ssl = true |
              .services.CoAuthoring.token.enable.browser = true |
              .services.CoAuthoring.token.enable.request.inbox = true |
              .services.CoAuthoring.token.enable.request.outbox = true |
              .services.CoAuthoring.secret.inbox.string = "'"$(cat ${cfg.jwtSecretFile})"'" |
              .services.CoAuthoring.secret.outbox.string = "'"$(cat ${cfg.jwtSecretFile})"'" |
              .services.CoAuthoring.secret.session.string = "'"$(cat ${cfg.jwtSecretFile})"'" |
            ''}
              .rabbitmq.url = "${cfg.rabbitmqUrl}"
              ' /run/onlyoffice/config/default.json | sponge /run/onlyoffice/config/default.json

            export PGPASSWORD=$(cat ${cfg.postgresPasswordFile})
            if psql \
                --host svc-pg01.dd-ix.net \
                --port 5432 \
                --username onlyoffice \
                --dbname onlyoffice \
                --command "SELECT 'task_result'::regclass;" >/dev/null; then
              psql \
                --host svc-pg01.dd-ix.net \
                --port 5432 \
                --username onlyoffice \
                --dbname onlyoffice \
                -f "${cfg.package}/var/www/onlyoffice/documentserver/server/schema/postgresql/removetbl.sql"
              psql \
                --host svc-pg01.dd-ix.net \
                --port 5432 \
                --username onlyoffice \
                --dbname onlyoffice \
                -f "${cfg.package}/var/www/onlyoffice/documentserver/server/schema/postgresql/createdb.sql"
            else
               psql \
                --host svc-pg01.dd-ix.net \
                --port 5432 \
                --username onlyoffice \
                --dbname onlyoffice \
                -f "${cfg.package}/var/www/onlyoffice/documentserver/server/schema/postgresql/createdb.sql"
            fi
          '')
      ];
    };
  };

  services = {
    postgresql = {
      enable = lib.mkForce false;
      package = pkgs.postgresql_16;
    };
    nextcloud = {
      enable = true;
      hostName = domain;
      https = true;
      package = pkgs.nextcloud28;
      configureRedis = true;
      config = {
        dbtype = "pgsql";
        dbname = "nextcloud";
        dbhost = "svc-pg01.dd-ix.net";
        dbpassFile = "${config.sops.secrets."cloud_db_pw".path}";
        overwriteProtocol = "https";
        adminuser = "admin";
        adminpassFile = "${config.sops.secrets."cloud_admin_pw".path}";
      };
      extraOptions = {
        allow_local_remote_servers = false;
        hide_login_form = true;
        mail_domain = "cloud.dd-ix.net";
        mail_from_address = "noreply";
        mail_smtpmode = "smtp";
        mail_smtphost = "mta.dd-ix.net";
        mail_smtpport = 25;
        mail_smtpsecure = ""; # ssl
        updatechecker = false;
        has_internet_connection = true;
        defaultapp = "files";
        appstoreenabled = true;
      };
      phpOptions = {
        "opcache.jit" = "tracing";
        "opcache.jit_buffer_size" = "100M";
        # recommended by nextcloud admin overview
        "opcache.interned_strings_buffer" = "16";
      };
      extraApps = {
        inherit (config.services.nextcloud.package.packages.apps) groupfolders polls user_oidc onlyoffice;
      };
      extraAppsEnable = true;
    };

    onlyoffice = {
      enable = true;
      package = nixpkgs-onlyoffice.onlyoffice-documentserver;
      hostname = "office.${config.deployment-dd-ix.domain}";
      postgresName = "onlyoffice"; # dbname
      postgresHost = "svc-pg01.dd-ix.net";
      postgresUser = "onlyoffice";
      postgresPasswordFile = config.sops.secrets."office_db_pw".path;
      jwtSecretFile = config.sops.secrets."office_jwt_secret".path;
    };

    nginx.virtualHosts = {
      "cloud.${config.deployment-dd-ix.domain}" = {
        listen = [{
          addr = "[::]:443";
          proxyProtocol = true;
          ssl = true;
        }];

        onlySSL = true;
        useACMEHost = "cloud.${config.deployment-dd-ix.domain}";
      };
      "office.${config.deployment-dd-ix.domain}" = {
        listen = [{
          addr = "[::]:443";
          proxyProtocol = true;
          ssl = true;
        }];

        onlySSL = true;
        useACMEHost = "office.${config.deployment-dd-ix.domain}";
      };
    };
  };
}
