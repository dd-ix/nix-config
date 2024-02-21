{ lib, config, ... }:
{
  services.sflow-exporter = {
    enable = true;
    metaPath = "/var/lib/sflow_exporter/meta.yaml";
  };

  services.nginx = {
    enable = true;
    virtualHosts."svc-exp01.dd-ix.net" = {
      forceSSL = true;
      useACMEHost = "svc-exp01.dd-ix.net";

      locations."/" =
        let
          metricsAddr = config.services.sflow-exporter.listen.metrics.addr;
        in
        {
          proxyPass = "http://${if (lib.hasInfix ":" metricsAddr) then "[${metricsAddr}]" else metricsAddr}:${toString config.services.sflow-exporter.listen.metrics.port}";
        };
    };
  };
}
