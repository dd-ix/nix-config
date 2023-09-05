{ pkgs, config, lib, ... }: {

services.vaultwarden.enable = true;
services.vaultwarden.config = {
  DOMAIN = "https://bitwarden.example.com";
  SIGNUPS_ALLOWED = false;
services.vaultwarden.dbBackend = "postgresql";
services.vaultwarden.environmentFile = /var/lib/vaultwarden.env;

services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    # Use recommended settings
    recommendedGzipSettings = true;

    virtualHosts."vautwarden.dd-ix.net" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8000";
        proxyWebsockets = true;
        };
      };
    };
  };
}
