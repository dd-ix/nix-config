{ config, ... }:

{
  sops.secrets = {
    "bookstack/app_key".owner = config.services.bookstack.user;
    "bookstack/oidc_secret".owner = config.services.bookstack.user;
    "bookstack/db_pass".owner = config.services.bookstack.user;
  };

  services = {
    bookstack = {
      enable = true;
      hostname = "wiki.${config.dd-ix.domain}";

      settings = {
        MAIL_FROM = "noreply@wiki.dd-ix.net";
        MAIl_FROM_NAME = "DD-IX-Wiki";
        MAIL_HOST = "svc-mta01.dd-ix.net";
        MAIL_PORT = 25;

        DB_USERNAME = "bookstack";
        DB_PASSWORD_FILE = config.sops.secrets."bookstack/db_pass".path;
        DB_DATABASE = "bookstack";
        DB_HOST = "svc-mari01.dd-ix.net";

        APP_URL = "https://wiki.${config.dd-ix.domain}";
        APP_KEY_FILE = config.sops.secrets."bookstack/app_key".path;

        AUTH_METHOD = "oidc";
        AUTH_AUTO_INITIATE = true;
        OIDC_NAME = ''"DD-IX Auth"'';
        OIDC_DISPLAY_NAME_CLAIMS = "name";
        OIDC_CLIENT_ID = "KTqcn54vUSLrQxMQLnXi8xdH8RPKclqfePL4ZWpT";
        OIDC_CLIENT_SECRET_FILE = config.sops.secrets."bookstack/oidc_secret".path;
        OIDC_ISSUER = "https://auth.${config.dd-ix.domain}/application/o/wiki/";
        OIDC_ISSUER_DISCOVER = true;

        OIDC_USER_TO_GROUPS = true;
        OIDC_GROUPS_CLAIM = "groups";
        OIDC_REMOVE_FROM_GROUPS = true;
      };

      nginx = {
        listen = [{
          addr = "[::]";
          port = 443;
          proxyProtocol = true;
          ssl = true;
        }];

        onlySSL = true;
        useACMEHost = "wiki.${config.dd-ix.domain}";
      };
    };
  };
}
