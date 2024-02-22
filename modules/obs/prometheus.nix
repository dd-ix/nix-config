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
      {
        job_name = "node_exporter";
        static_configs = [{ targets = [ "ixp-rs01.dd-ix.net:9100" "ixp-rs02.dd-ix.net:9100" "svc-fw01.dd-ix.net:9100" ]; }];
      }
      {
        job_name = "openrc_exporter";
        static_configs = [{ targets = [ "ixp-rs01.dd-ix.net:9816" "ixp-rs02.dd-ix.net:9816" "svc-fw01.dd-ix.net:9816" ]; }];
      }
      {
        job_name = "bird_exporter";
        static_configs = [{ targets = [ "ixp-rs01.dd-ix.net:9324" "ixp-rs02.dd-ix.net:9324" ]; }];
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
