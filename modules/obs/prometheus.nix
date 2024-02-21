{ config, ... }:
{
  services.prometheus = {
    enable = true;
    webExternalUrl = "https://svc-prom01.dd-ix.net";
    scrapeConfigs = [
      {
        job_name = "sflow_exporter";
        static_configs = [{ targets = [ "svc-exp01.dd-ix.net:9100" ]; }];
      }
    ];
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
