{ self, config, pkgs, ... }:

let
  kuma_domain = "status.${config.dd-ix.domain}";
in
{
  security.acme.certs.${kuma_domain}.email = "${config.security.acme.defaults.email}";
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
	  locations."/" = {
            proxyPass = "http://${config.services.uptime-kuma.settings.HOST}:${config.services.uptime-kuma.settings.PORT}";
	  };
          forceSSL = true;
          enableACME = true;
        };
      };
    };
  };
}
