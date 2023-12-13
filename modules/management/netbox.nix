{ config, pkgs, ... }:
{
  sops.secrets.netbox_db_pass.owner = "netbox";
  sops.secrets.netbox_secret_key_file.owner = "netbox";
  sops.secrets.keycloak_social_auth_secret.owner = "netbox";

  services = {
    postgresql = {
      enable = true;
      ensureUsers = [
        {
          name = "netbox";
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = [ "netbox" ];
    };

    netbox = {
      enable = true;
      package = pkgs.netbox;
      port = 9502;
      listenAddress = "127.0.0.1";
      secretKeyFile = "${config.sops.secrets.netbox_secret_key_file.path}";
      settings = {
        # https://stackoverflow.com/questions/53550321/keycloak-gatekeeper-aud-claim-and-client-id-do-not-match
        REMOTE_AUTH_ENABLED = true;
        REMOTE_AUTH_AUTO_CREATE_USER = true;
        REMOTE_AUTH_GROUP_SYNC_ENABLED = true;
        REMOTE_AUTH_BACKEND = "social_core.backends.keycloak.KeycloakOAuth2";

        #REMOTE_AUTH_GROUP_SEPARATOR=",";
        REMOTE_AUTH_SUPERUSER_GROUPS = [ "superuser" ];
        REMOTE_AUTH_STAFF_GROUPS = [ "staff" ];
        REMOTE_AUTH_DEFAULT_GROUPS = [ "staff" ];

        SOCIAL_AUTH_KEYCLOAK_KEY = "netbox";
        SOCIAL_AUTH_KEYCLOAK_PUBLIC_KEY = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxeOlZAP0/GDzHW29AVq9svu7CMnqqm2JJmAheFZboBGYhGr5obusczoblHdUhv0O5HOzHY8x+vMyQ7RTbCH2j7ezY2b96kUwcSdNbXIQGMpxSM44m2XGr/FaPl1qqDm5NIyNUo0mTPO62Z5hQ1Uocup9Bs29w521QepR15JuzMBc1NeIo2tQ0oid/nhqfacUPsJRyLqWbpy1Jcpvo8sf///uWlVpg64au6Fum4zJiIhj0/JHMdMJU+z7V5BcxIdcY+i8WXdn7YQZ1sFwcuO4jAO+Wb4ZL7JzBqbxdZQeUPZU8flfPqXQwBibi8bwbF6pQWdV49EKOxgvn+zI8+GEvwIDAQAB";
        SOCIAL_AUTH_KEYCLOAK_AUTHORIZATION_URL = "https://auth.${config.deployment-dd-ix.domain}/realms/DD-IX/protocol/openid-connect/auth";
        SOCIAL_AUTH_KEYCLOAK_ACCESS_TOKEN_URL = "https://auth.${config.deployment-dd-ix.domain}/realms/DD-IX/protocol/openid-connect/token";
        SOCIAL_AUTH_KEYCLOAK_ID_KEY = "email";
        SOCIAL_AUTH_JSONFIELD_ENABLED = true;
        SOCIAL_AUTH_VERIFY_SSL = false;
        #SOCIAL_AUTH_OIDC_SCOPE = [ "groups" "roles"];
      };

      keycloakClientSecret = "${config.sops.secrets.keycloak_social_auth_secret.path}";
    };

    nginx = {
      enable = true;
      virtualHosts."dcim.${config.deployment-dd-ix.domain}" = {
        locations = {
          "/static/".alias = "${config.services.netbox.dataDir}/static/";
          "/".proxyPass = "http://127.0.0.1:9502";
        };
        forceSSL = true;
        enableACME = true;
      };
      virtualHosts."netbox.${config.deployment-dd-ix.domain}" = {
        locations = {
          "/".return = "301 https://dcim.${config.deployment-dd-ix.domain}$request_uri";
        };
        forceSSL = true;
        enableACME = true;
      };
      user = "netbox";
    };
  };

  # systemd.services.permission-netbox-setup = {
  #   enable = true;
  #   description = "change permissions of /var/lib/netbox/static";
  #   wantedBy = [ "multi-user.target" ];
  #   after = [ "netbox.service" ];
  #   serviceConfig.Type = "oneshot";

  #   path = [ pkgs.sudo ];
  #   script = ''
  #     chown -R nginx /var/lib/netbox/static/
  #   '';
  # };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
