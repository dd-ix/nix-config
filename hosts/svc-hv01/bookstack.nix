{ config, pkgs, ... }: {
  sops.secrets.bookstack_appkey.owner = config.services.bookstack.user;
  sops.secrets.postgres_bookstack.owner = config.services.bookstack.user;
  sops.secrets.bookstack_oidc_secret.owner = config.services.bookstack.user;

  services = {
    bookstack = {
      enable = true;
      hostname = "wiki.${config.dd-ix.domain}";
      appURL = "https://wiki.${config.dd-ix.domain}";
      mail = {
        from = "noreply@wiki.dd-ix.net";
        fromName = "DD-IX-Wiki";
        host = "svc-mta01.dd-ix.net";
        port = 25;
      };

      nginx = {
        listen = [{
          addr = "[::]:443";
          proxyProtocol = true;
          ssl = true;
        }];

        onlySSL = true;
        useACMEHost = "wiki.${config.dd-ix.domain}";
      };

      # Bookstack requires mariadb or mysql :<
      database = {
        user = "bookstack";
        host = "localhost";
        name = "bookstack";
        createLocally = true;
      };

      appKeyFile = config.sops.secrets.bookstack_appkey.path;
      config = {
        AUTH_METHOD = "oidc";
        AUTH_AUTO_INITIATE = true;
        OIDC_NAME = ''"DD-IX Auth"'';
        OIDC_DISPLAY_NAME_CLAIMS = "name";
        OIDC_CLIENT_ID = "KTqcn54vUSLrQxMQLnXi8xdH8RPKclqfePL4ZWpT";
        OIDC_CLIENT_SECRET._secret = "${config.sops.secrets.bookstack_oidc_secret.path}";
        OIDC_ISSUER = "https://auth.${config.dd-ix.domain}/application/o/wiki/";
        OIDC_ISSUER_DISCOVER = true;

        OIDC_USER_TO_GROUPS = true;
        OIDC_GROUPS_CLAIM = "groups";
        OIDC_REMOVE_FROM_GROUPS = true;
      };
    };
    mysql = {
      package = pkgs.mariadb;
      enable = true;
    };
    mysqlBackup = {
      enable = true;
      databases = [ "bookstack" ];
    };
  };
}
