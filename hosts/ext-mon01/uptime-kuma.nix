{ config, ... }:

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
        "status.${config.dd-ix.domain}" = {
          locations = {
            "/" = {
              proxyPass = "http://${config.services.uptime-kuma.settings.HOST}:${config.services.uptime-kuma.settings.PORT}";
            };
            "= /".return = "301 /status/dd-ix";
          };
          forceSSL = true;
          enableACME = true;
        };
        "status.elbforge.org" = {
          locations = {
            "/" = {
              proxyPass = "http://${config.services.uptime-kuma.settings.HOST}:${config.services.uptime-kuma.settings.PORT}";
            };
            "= /".return = "301 /status/elbforge";
          };
          forceSSL = true;
          enableACME = true;
        };
      };
    };
  };
}
