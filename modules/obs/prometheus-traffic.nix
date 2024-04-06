{ config, ... }:
{
  services.prometheus = {
    enable = true;
    retentionTime = "99y";
    webExternalUrl = "https://svc-prom02.dd-ix.net";
    scrapeConfigs = [
      {
        job_name = "sflow_exporter";
        static_configs = [{ targets = [ "svc-exp01.dd-ix.net:9144" ]; }];
        scrape_interval = "15s";
      }
    ];
  };

  services.nginx = {
    enable = true;
    virtualHosts."svc-prom02.dd-ix.net" = {
      forceSSL = true;
      useACMEHost = "svc-prom02.dd-ix.net";

      locations."/" = {
        proxyPass = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
      };
    };
  };
}
