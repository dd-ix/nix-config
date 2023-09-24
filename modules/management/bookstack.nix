{ config, lib, pkgs, ... }: {
  sops.secrets.bookstack_appkey.owner = config.services.bookstack.user;
  sops.secrets.postgres_bookstack.owner = config.services.bookstack.user;
  sops.secrets.bookstack_oidc_secret.owner = config.services.bookstack.user;

  services = {
    bookstack = {
      enable = true;
      hostname = "wiki.dd-ix.net";
      appURL = "https://wiki.dd-ix.net";
      mail = {
        user = "wiki@dd-ix.net";
        from = "wiki@dd-ix.net";
      };

      nginx = {
        enableACME = true;
        forceSSL = true;
      };

      # Bookstack requires mariadb or mysql :<
      database = {
        user = "bookstack";
        host = "localhost";
        name = "bookstack";
        passwordFile = config.sops.secrets.postgres_bookstack.path;
      };

      appKeyFile = config.sops.secrets.bookstack_appkey.path;
      config = {
        AUTH_METHOD = "oidc";
        AUTH_AUTO_INITIATE = true;
        OIDC_NAME = ''"DD-IX Bookstack"'';
        OIDC_CLIENT_ID = "bookstack";
        OIDC_CLIENT_SECRET._secret = config.sops.secrets.bookstack_oidc_secret.path;
        OIDC_ISSUER = "https://keycloak.dd-ix.net/";
        OIDC_AUTH_ENDPOINT = "https://keycloak.dd-ix.net/realms/DD-IX/protocol/openid-connect/auth";
        OIDC_TOKEN_ENDPOINT = "https://keycloak.dd-ix.net/realms/DD-IX/protocol/openid-connect/token";
        OIDC_ISSUER_DISCOVER = true;
        OIDC_USER_TO_GROUPS = true;
        OIDC_GROUPS_CLAIM = "groups";
        OIDC_ADDITIONAL_SCOPES = "groups";
        OIDC_REMOVE_FROM_GROUPS = true;

        # does not work yet, requires newer bookstash version
        # OIDC_USER_TO_GROUPS = true;
        # OIDC_GROUPS_CLAIM = "groups";
        # OIDC_REMOVE_FROM_GROUPS = true;
      };
    };
    mysql = {
      package = pkgs.mariadb;
      enable = true;
    };
  };
}
