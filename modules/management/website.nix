{ pkgs, config, ... }: {
  services.nginx = {
    enable = true;
    virtualHosts = {
      "${config.deployment-dd-ix.domain}" = {
        enableACME = true;
        forceSSL = true;

        basicAuth =  {
          "dd-ix" = "web-dd-ix";
        };
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
      url = "https://content.${config.deployment-dd-ix.domain}/";
    };
  };
}
