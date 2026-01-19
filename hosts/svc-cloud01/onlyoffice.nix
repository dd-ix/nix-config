{ config, pkgs, ... }:

{
  sops = {
    secrets = {
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

  systemd.services.nextcloud-onlyoffice-config = {
    wantedBy = [ "multi-user.target" ];
    after = [ "nextcloud-setup.service" ];

    path = [ config.services.nextcloud.occ ];
    script = ''
      nextcloud-occ config:app:set onlyoffice DocumentServerUrl --value "https://office.${config.dd-ix.domain}"
      nextcloud-occ config:app:set onlyoffice StorageUrl --value "https://cloud.${config.dd-ix.domain}/"
      nextcloud-occ config:app:set onlyoffice jwt_secret --value $(cat ${config.sops.secrets."onlyoffice/jwt_secret".path}) >/dev/null
    '';
  };

  services = {
    nginx.virtualHosts."office.${config.dd-ix.domain}" = {
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

    # onlyoffice dependencies
    rabbitmq.enable = true;
    redis.servers.onlyoffice = {
      enable = true;
      port = 6379;
    };
    nextcloud.extraApps = {
      inherit (config.services.nextcloud.package.packages.apps)
        onlyoffice;
    };
  };

  # nix-prefetch-docker --image-name onlyoffice/documentserver --image-tag 9.2.1.1
  virtualisation.oci-containers.containers.onlyoffice = {
    image = "onlyoffice/documentserver:9.2.1.1";
    imageFile = pkgs.dockerTools.pullImage {
      imageName = "onlyoffice/documentserver";
      imageDigest = "sha256:fd00acbbbde3d8b1ead9b933aafa7c2df77e62c48b1b171886e6bef343c13882";
      hash = "sha256-xlj9asSFKKD8iCwMYw3AeAOA6mjNKU/f4YX0SCGr4yw=";
      finalImageName = "onlyoffice/documentserver";
      finalImageTag = "9.2.1.1";
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
        "${pkgs.quicksand}/share/fonts/quicksand:/usr/share/fonts/truetype/Quicksand:ro"
      ];
    entrypoint = "/bin/bash";
    cmd = [ "/onlyoffice-entrypoint.sh" ];
  };
}
