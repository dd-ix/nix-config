{ config, ... }:

{
  services.loki = {
    enable = true;
    configuration = {
      auth_enabled = false;

      server = { http_listen_port = 3100; };

      common = {
        instance_addr = "::1";
        path_prefix = "/var/lib/loki";
        storage.filesystem = {
          chunks_directory = "/var/lib/loki/chunks";
          rules_directory = "/var/lib/loki/rules";
        };
        replication_factor = 1;
        ring.kvstore.store = "inmemory";
      };

      schema_config.configs = [{
        # https://grafana.com/docs/loki/latest/operations/storage/schema/
        # DONT CHANGE THIS
        from = "2025-05-24";
        index = {
          period = "24h";
          prefix = "index_";
        };
        object_store = "filesystem";
        schema = "v13";
        store = "tsdb";
      }];

      analytics.reporting_enabled = false;
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts."svc-log01.dd-ix.net" = {
      forceSSL = true;
      useACMEHost = "svc-log01.dd-ix.net";

      locations."/" = {
        proxyPass = "http://[${config.services.loki.configuration.common.instance_addr}]:${toString config.services.loki.configuration.server.http_listen_port}";
      };
    };
  };
}
