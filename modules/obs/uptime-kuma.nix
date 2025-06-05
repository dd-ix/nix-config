{ self, config, pkgs, ... }:

let
  kuma_domain = "status.${config.dd-ix.domain}";
in
{
  services = {
    uptime-kuma = {
      enable = true;
      settings = {
        DATA_DIR = "/var/lib/uptime-kuma/";
        NODE_ENV = lib.mkDefault "production";
        HOST = lib.mkDefault "127.0.0.1";
        PORT = lib.mkDefault "3001";
      };
    };
    nginx = {
      enable = true;
      virtualHosts = {
        "${kuma_domain}" = {
          listen = [{
            addr = "[::]:443";
            proxyProtocol = true;
            ssl = true;
          }];
	  locations."/" = {
            proxyPass = "http://127.0.0.1:3001";
	  };

          onlySSL = true;
          useACMEHost = kuma_domain;
        };
      };
    };
  };
}
