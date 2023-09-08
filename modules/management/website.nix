{ pkgs, config, ... }: {

  sops.secrets."nginx.htpasswd".owner = "netbox";
  sops.secrets.listmonk_admin.owner = config.dd-ix.foundation.user;
  services.nginx = {
    enable = true;
    virtualHosts = {
      "${config.deployment-dd-ix.domain}" = {
        enableACME = true;
        forceSSL = true;
        basicAuthFile = config.sops.secrets."nginx.htpasswd".path;
        locations = {
          "=/robots.txt" = {
            return = "200 \"User-agent: *\\nDisallow: /\\n\"";
          };
          "/" = {
            proxyPass = "http://127.0.0.1:4000/";
          };
        };
      };
      "content.${config.deployment-dd-ix.domain}" = {
        enableACME = true;
        forceSSL = true;
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
        allowed_lists = [8 9];
      };
      url = "https://content.${config.deployment-dd-ix.domain}/";
    };
  };
}
