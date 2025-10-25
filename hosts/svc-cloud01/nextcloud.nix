{ config, pkgs, lib, ... }:

let
  domain = "cloud.${config.dd-ix.domain}";
in
{
  sops = {
    secrets = {
      "nextcloud/admin_pass" = { };
      "nextcloud/db_pass" = { };
      "onlyoffice/jwt_secret" = { };
      "onlyoffice/db_pass" = { };
    };
    templates."onlyoffice/env".content = ''
      JWT_SECRET=${config.sops.placeholder."onlyoffice/jwt_secret"}
      DB_TYPE=postgres
      DB_HOST=svc-pg01.dd-ix.net
      DB_NAME=onlyoffice
      DB_USER=onlyoffice
      DB_PWD=${config.sops.placeholder."onlyoffice/db_pass"}
      REDIS_SERVER_HOST=${config.services.redis.servers.onlyoffice.bind}
      REDIS_SERVER_PORT=${builtins.toString config.services.redis.servers.onlyoffice.port}
      AMQP_URI=amqp://${config.services.rabbitmq.listenAddress}:${builtins.toString config.services.rabbitmq.port}
    '';
  };

  systemd.services = {
    nextcloud-setup.after = [ "network.target" ];
    nextcloud-update-db.after = [ "network.target" ];
  };

  services = {
    postgresql = {
      enable = lib.mkForce false;
    };
    nextcloud = {
      enable = true;
      package = pkgs.nextcloud31;
      hostName = domain;
      https = true;
      config = {
        dbtype = "pgsql";
        dbname = "nextcloud";
        dbhost = "svc-pg01.dd-ix.net";
        dbuser = "nextcloud";
        dbpassFile = "${config.sops.secrets."nextcloud/db_pass".path}";
        adminuser = "admin";
        adminpassFile = "${config.sops.secrets."nextcloud/admin_pass".path}";
      };
      settings = {
        default_phone_region = "DE";
        maintenance_window_start = "4";
        allow_local_remote_servers = false;
        hide_login_form = true;
        mail_domain = "cloud.dd-ix.net";
        mail_from_address = "noreply";
        mail_smtpmode = "smtp";
        mail_smtphost = "svc-mta01.dd-ix.net";
        mail_smtpport = 25;
        mail_smtpsecure = ""; # ssl
        has_internet_connection = true;
        defaultapp = "files";
        appstoreenabled = true;
        overwriteprotocol = "https";
        #loglevel = 0;
      };
      phpOptions = {
        # recommended by nextcloud admin overview
        "opcache.interned_strings_buffer" = 16; # default 8
        # https://docs.nextcloud.com/server/24/admin_manual/installation/server_tuning.html#enable-php-opcache
        "opcache.revalidate_freq" = 60; # default 1
        # https://docs.nextcloud.com/server/latest/admin_manual/installation/server_tuning.html#:~:text=opcache.jit%20%3D%201255%20opcache.jit_buffer_size%20%3D%20128m
        "opcache.jit" = 1255;
        "opcache.jit_buffer_size" = "128M";
      };
      extraApps = {
        inherit (config.services.nextcloud.package.packages.apps)
          groupfolders polls user_oidc onlyoffice forms;
      };
      extraAppsEnable = true;
    };

    nginx.virtualHosts = {
      "cloud.${config.dd-ix.domain}" = {
        listen = [
          {
            addr = "[::]";
            port = 443;
            proxyProtocol = true;
            ssl = true;
          }
          {
            addr = "[::1]";
            port = 443;
            ssl = true;
          }
        ];

        onlySSL = true;
        useACMEHost = config.services.nextcloud.hostName;
      };
      "office.${config.dd-ix.domain}" = {
        listen = [
          {
            addr = "[::]";
            port = 443;
            proxyProtocol = true;
            ssl = true;
          }
          {
            addr = "[::1]";
            port = 443;
            ssl = true;
          }
          {
            addr = "127.0.0.1";
            port = 443;
            ssl = true;
          }
        ];

        onlySSL = true;
        useACMEHost = "office.${config.dd-ix.domain}";
        locations."/" = {
          proxyPass = "http://127.0.0.1:80";
          proxyWebsockets = true;
        };
      };
    };

    # onlyoffice dependencies
    rabbitmq.enable = true;
    redis.servers.onlyoffice = {
      enable = true;
      port = 6379;
    };
  };

  # nix-prefetch-docker --image-name onlyoffice/documentserver --image-tag 9.1.0.1
  virtualisation.oci-containers.containers.onlyoffice = {
    image = "onlyoffice/documentserver:9.1.0.1";
    imageFile = pkgs.dockerTools.pullImage {
      imageName = "onlyoffice/documentserver";
      imageDigest = "sha256:34b92f4a67bfd939bd6b75893e8217556e3b977f81e49472f7e28737b741ba1d";
      hash = "sha256-JtFYwrStIaHCBmHLynPGtW14rZUOp9tCMoP5HfeWl/w=";
      finalImageName = "onlyoffice/documentserver";
      finalImageTag = "9.1.0.1";
    };
    environmentFiles = [ config.sops.templates."onlyoffice/env".path ];
    extraOptions = [ "--network=host" ];
    volumes =
      let
        # https://github.com/ONLYOFFICE/Docker-DocumentServer/blob/ba4961c28f860daae38c27d40fc399f3bb59decb/run-document-server.sh
        entrypoint = pkgs.writeText "onlyoffice-entrypoint.sh" /* bash */ ''
          #!/bin/bash
          umask 0022

          APP_DIR="/var/www/''${COMPANY_NAME}/documentserver"
          CONF_DIR="/etc/''${COMPANY_NAME}/documentserver"
          ONLYOFFICE_DEFAULT_CONFIG=''${CONF_DIR}/local.json
          JSON_BIN=''${APP_DIR}/npm/json
          JSON="''${JSON_BIN} -q -f ''${ONLYOFFICE_DEFAULT_CONFIG}"
          ''${JSON} -I -e "this.services.CoAuthoring.sql.pgPoolExtraOptions ||= {}; this.services.CoAuthoring.sql.pgPoolExtraOptions.ssl = true"
          exec /app/ds/run-document-server.sh
        '';
      in
      [
        "/var/lib/onlyoffice/cache:/var/lib/onlyoffice/documentserver/App_Data/cache"
        "/var/lib/onlyoffice/data:/var/www/onlyoffice/Data"
        "${entrypoint}:/onlyoffice-entrypoint.sh:ro"
        "${pkgs.dm-sans}/share/fonts/truetype:/usr/share/fonts/truetype/DeepMindSans:ro"
        "${pkgs.dm-mono}/share/fonts/truetype:/usr/share/fonts/truetype/DMMono:ro"
      ];
    entrypoint = "/bin/bash";
    cmd = [ "/onlyoffice-entrypoint.sh" ];
  };
}
