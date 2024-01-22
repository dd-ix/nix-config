{ config, lib, pkgs, ... }: {
  sops.secrets.bookstack_appkey.owner = config.services.bookstack.user;
  sops.secrets.postgres_bookstack.owner = config.services.bookstack.user;
  sops.secrets.bookstack_oidc_secret.owner = config.services.bookstack.user;

  services = {
    bookstack = {
      enable = true;
      hostname = "wiki.${config.deployment-dd-ix.domain}";
      appURL = "https://wiki.${config.deployment-dd-ix.domain}";
      mail = {
        from = "noreply@wiki.dd-ix.net";
        fromName = "DD-IX-Wiki";
        host = "mta.dd-ix.net";
        port = 25;
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
        createLocally = true;
      };

      appKeyFile = config.sops.secrets.bookstack_appkey.path;
      config = {
        AUTH_METHOD = "oidc";
        AUTH_AUTO_INITIATE = true;
        OIDC_NAME = ''"DD-IX Bookstack"'';
        OIDC_DISPLAY_NAME_CLAIMS = "name";
        OIDC_CLIENT_ID = "bookstack";
        OIDC_CLIENT_SECRET._secret = "${config.sops.secrets.bookstack_oidc_secret.path}";
        OIDC_ISSUER = "https://keycloak.auth.${config.deployment-dd-ix.domain}/realms/DD-IX";
        OIDC_ISSUER_DISCOVER = true;

        OIDC_USER_TO_GROUPS = true;
        OIDC_GROUPS_CLAIM = "resource_access.bookstack.roles";
        OIDC_REMOVE_FROM_GROUPS = true;
      };
    };
    mysql = {
      package = pkgs.mariadb;
      enable = true;
    };
  };
}
