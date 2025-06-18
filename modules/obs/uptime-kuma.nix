{ self, config, ... }:

let
  kuma_domain = "status.${config.dd-ix.domain}";
in
{
  services = {
    uptime-kuma = {
      enable = true;
      settings = {
        DATA_DIR = "/var/lib/uptime-kuma/";
        NODE_ENV = "production";
        HOST = "127.0.0.1";
        PORT = "3001";
      };
    };

    nginx = {
      enable = true;
      virtualHosts = {
        "${kuma_domain}" = {
          locations = {
            "/".proxyPass = "http://${config.services.uptime-kuma.settings.HOST}:${config.services.uptime-kuma.settings.PORT}";
            "= /".return = "302 https://${kuma_domain}/status/dd-ix";
            "= /icon.svg" = {
              alias = "${self}/resources/";
              tryFiles = "logo.svg =404";
              extraConfig = ''
                expires max;
                access_log off;
              '';
            };
          };
          forceSSL = true;
          enableACME = true;
        };
      };
    };
  };
}
