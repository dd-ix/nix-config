{ lib, config, ... }:

{
  sops = {
    secrets."hedgedoc/db_pass" = { };
    secrets."hedgedoc/oauth2_client_secret" = { };
    templates."hedgedoc/env".content = ''
      CMD_DB_PASSWORD=${config.sops.placeholder."hedgedoc/db_pass"}
      CMD_OAUTH2_CLIENT_SECRET=${config.sops.placeholder."hedgedoc/oauth2_client_secret"}
    '';
  };

  services = {
    hedgedoc = {
      enable = true;
      configureNginx = true;
      environmentFile = config.sops.templates."hedgedoc/env".path;
      settings = {
        protocolUseSSL = true;
        domain = "pad.${config.dd-ix.domain}";
        db = {
          dialect = "postgres";
          username = "hedgedoc";
          database = "hedgedoc";
          host = "svc-pg01.dd-ix.net";
          port = "5432";
          dialectOptions.ssl = true;
        };
        oauth2 = {
          providername = "DD-IX Auth";
          clientID = "kvfIfoiWcWdN5NwarjF43gCdoWuPjM37K5eSnbJM";
          scope = "openid email profile";
          userProfileURL = "https://auth.${config.dd-ix.domain}/application/o/userinfo/";
          tokenURL = "https://auth.${config.dd-ix.domain}/application/o/token/";
          authorizationURL = "https://auth.${config.dd-ix.domain}/application/o/authorize/";
          userProfileUsernameAttr = "preferred_username";
          userProfileDisplayNameAttr = "name";
          userProfileEmailAttr = "email";
        };
        allowAnonymous = false;
        allowAnonymousEdits = true;
        defaultPermission = "limited";
        # disallow email login
        email = false;
      };
    };

    nginx.virtualHosts. "pad.${config.dd-ix.domain}" = {
      listen = [{
        addr = "[::]";
        port = 443;
        proxyProtocol = true;
        ssl = true;
      }];

      onlySSL = true;
      useACMEHost = "pad.${config.dd-ix.domain}";

      forceSSL = lib.mkForce false;
    };
  };
}
