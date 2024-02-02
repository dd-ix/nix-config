{ config, ... }: {

  sops.secrets.listmonk_admin.owner = config.dd-ix.foundation.user;
  services.nginx = {
    enable = true;
    virtualHosts = {
      "www.${config.deployment-dd-ix.domain}" = {
        listen = [{
          addr = "[::]:443";
          proxyProtocol = true;
          ssl = true;
        }];

        onlySSL = true;
        useACMEHost = "www.${config.deployment-dd-ix.domain}";

        locations = {
          "/".return = "301 https://${config.deployment-dd-ix.domain}$request_uri";
        };
      };
      "${config.deployment-dd-ix.domain}" = {
        listen = [{
          addr = "[::]:443";
          proxyProtocol = true;
          ssl = true;
        }];

        onlySSL = true;
        useACMEHost = config.deployment-dd-ix.domain;

        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:4000/";
          };
        };
      };
      "content.${config.deployment-dd-ix.domain}" = {
        listen = [{
          addr = "[::]:443";
          proxyProtocol = true;
          ssl = true;
        }];

        onlySSL = true;
        useACMEHost = "content.${config.deployment-dd-ix.domain}";

        locations = {
          "/" = {
            proxyPass = "http://${config.dd-ix.foundation.http.host}:${toString config.dd-ix.foundation.http.port}/";
          };
        };
      };
    };
  };

  dd-ix = {
    presence = {
      enable = true;
    };
    foundation = {
      enable = true;
      http = {
        host = "127.0.0.1";
        port = 9123;
      };
      listmonk = {
        host = "http://127.0.0.1";
        port = 9820;
        user = config.services.listmonk.settings.app.admin_username;
        passwordFile = config.sops.secrets.listmonk_admin.path;
        allowed_lists = [ 9 ];
      };
      url = "https://content.${config.deployment-dd-ix.domain}/";
    };
  };
}
