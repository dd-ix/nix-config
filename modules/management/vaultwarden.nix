{ pkgs, config, lib, ... }

services.vaultwarden.enable = true;


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
