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
      {
        job_name = "knot_exporter";
        static_configs = [{ targets = [ "ixp-as11201.dd-ix.net:9433" ]; }];
        metric_relabel_configs = [{
          source_labels = [ "__name__" ];
          regex = "knot_stats_query_type_total";
          action = "keep";
        }];
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
