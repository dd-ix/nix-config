{ self, config, pkgs, lib, ... }:
{
  sops.secrets."dcim_secret_key" = {
    sopsFile = self + "/secrets/management/dcim.yaml";
    owner = config.systemd.services.netbox.serviceConfig.User;
  };

  sops.secrets."dcim_db_pw" = {
    sopsFile = self + "/secrets/management/dcim.yaml";
    owner = config.systemd.services.netbox.serviceConfig.User;
  };

  sops.secrets."dcim_oidc_secret" = {
    sopsFile = self + "/secrets/management/dcim.yaml";
    owner = config.systemd.services.netbox.serviceConfig.User;
  };

  users.users. nginx.extraGroups = [ "netbox" ];

  services = {
    netbox = {
      enable = true;
      package = pkgs.netbox;
      secretKeyFile = "${config.sops.secrets.dcim_secret_key.path}";
      plugins = python3Packages: with python3Packages; [ python-jose ];
      settings = {
        ALLOWED_HOSTS = [ "dcim.${config.deployment-dd-ix.domain}" ];

        DATABASE = {
          NAME = "netbox";
          USER = "netbox";
          HOST = lib.mkForce "svc-pg01.dd-ix.net";
          PORT = 5432;
          PASSWORD = "";
        };

        REMOTE_AUTH_ENABLED = true;
        REMOTE_AUTH_BACKEND = "social_core.backends.open_id_connect.OpenIdConnectAuth";
        SOCIAL_AUTH_OIDC_ENDPOINT = "https://auth.dd-ix.net/application/o/dcim/";
        SOCIAL_AUTH_OIDC_KEY = "ooCkcwLzdXcCMVJFGzZY0g0H2Y1gLmXHI2ZcPbva";
        LOGOUT_REDIRECT_URL = "https://auth.dd-ix.net/application/o/dcim/end-session/";

        # https://stackoverflow.com/questions/53550321/keycloak-gatekeeper-aud-claim-and-client-id-do-not-match
        #REMOTE_AUTH_AUTO_CREATE_USER = true;
        #REMOTE_AUTH_GROUP_SYNC_ENABLED = true;

        #REMOTE_AUTH_GROUP_SEPARATOR=",";
        #REMOTE_AUTH_SUPERUSER_GROUPS = [ "superuser" ];
        #REMOTE_AUTH_STAFF_GROUPS = [ "staff" ];
        #REMOTE_AUTH_DEFAULT_GROUPS = [ "staff" ];

        #SOCIAL_AUTH_KEYCLOAK_KEY = "netbox";
        #SOCIAL_AUTH_KEYCLOAK_PUBLIC_KEY = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxeOlZAP0/GDzHW29AVq9svu7CMnqqm2JJmAheFZboBGYhGr5obusczoblHdUhv0O5HOzHY8x+vMyQ7RTbCH2j7ezY2b96kUwcSdNbXIQGMpxSM44m2XGr/FaPl1qqDm5NIyNUo0mTPO62Z5hQ1Uocup9Bs29w521QepR15JuzMBc1NeIo2tQ0oid/nhqfacUPsJRyLqWbpy1Jcpvo8sf///uWlVpg64au6Fum4zJiIhj0/JHMdMJU+z7V5BcxIdcY+i8WXdn7YQZ1sFwcuO4jAO+Wb4ZL7JzBqbxdZQeUPZU8flfPqXQwBibi8bwbF6pQWdV49EKOxgvn+zI8+GEvwIDAQAB";
        #SOCIAL_AUTH_KEYCLOAK_AUTHORIZATION_URL = "https://keycloak.auth.${config.deployment-dd-ix.domain}/realms/DD-IX/protocol/openid-connect/auth";
        #SOCIAL_AUTH_KEYCLOAK_ACCESS_TOKEN_URL = "https://keycloak.auth.${config.deployment-dd-ix.domain}/realms/DD-IX/protocol/openid-connect/token";
        #SOCIAL_AUTH_KEYCLOAK_ID_KEY = "email";
        #SOCIAL_AUTH_JSONFIELD_ENABLED = true;
        #SOCIAL_AUTH_VERIFY_SSL = false;
        #SOCIAL_AUTH_OIDC_SCOPE = [ "groups" "roles"];
      };
      extraConfig = ''
        with open('${config.sops.secrets."dcim_db_pw".path}', 'r') as file:
          DATABASE['PASSWORD'] = file.read()

        with open('${config.sops.secrets."dcim_oidc_secret".path}', 'r') as file:
          SOCIAL_AUTH_OIDC_SECRET = file.read()
      '';
    };

    nginx = {
      enable = true;
      virtualHosts."dcim.${config.deployment-dd-ix.domain}" = {
        listen = [{
          addr = "[::]:443";
          proxyProtocol = true;
          ssl = true;
        }];

        onlySSL = true;
        useACMEHost = "dcim.${config.deployment-dd-ix.domain}";

        locations = {
          "/static/".alias = "${config.services.netbox.dataDir}/static/";
          "/".proxyPass = "http://${config.services.netbox.listenAddress}:${toString config.services.netbox.port}";
        };
      };
    };
  };
}
