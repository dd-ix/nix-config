{ config, ... }:
{
  services.prometheus = {
    enable = true;
    webExternalUrl = "https://svc-prom01.dd-ix.net";
  };

  services.nginx = {
    enable = true;
    virtualHosts."svc-prom01.dd-ix.net" = {
      forceSSL = true;
      useACMEHost = "svc-prom01.dd-ix.net";

      locations."/" = {
        proxyPass = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
      };
    };
  };
}
