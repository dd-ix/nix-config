{ self, config, lib, ... }:
{
  services.prometheus = {
    enable = true;
    webExternalUrl = "https://svc-prom01.dd-ix.net";
    scrapeConfigs = [
      {
        job_name = "sflow_exporter";
        static_configs = [{ targets = [ "svc-exp01.dd-ix.net:9144" ]; }];
        scrape_interval = "15s";
      }
      {
        job_name = "node_exporter";
        static_configs = [{
          targets =
            let
              toList = attrs: (builtins.map (key: lib.getAttr key attrs) (lib.attrNames attrs));

              # list of all nixos systems in this flake
              allSystems = toList self.nixosConfigurations;

              # filters out all the systems where monitoring is turned off
              monitoredSystems = builtins.filter (x: x.config.dd-ix.monitoring.enable == true) allSystems;

              # turns the hostname into an address
              extractAddress = host: "${host.config.dd-ix.microvm.hostName}.dd-ix.net:9100";

              # list of addresses
              listAddress = builtins.map extractAddress monitoredSystems;

            in
            [
              "ixp-rs01.dd-ix.net:9100"
              "ixp-rs02.dd-ix.net:9100"
              "svc-fw01.dd-ix.net:9100"
            ] ++ listAddress;
        }];
      }
      {
        job_name = "openrc_exporter";
        static_configs = [{
          targets = [
            "ixp-rs01.dd-ix.net:9816"
            "ixp-rs02.dd-ix.net:9816"
            "svc-fw01.dd-ix.net:9816"
          ];
        }];
      }
      {
        job_name = "bird_exporter";
        static_configs = [{
          targets = [
            "ixp-rs01.dd-ix.net:9324"
            "ixp-rs02.dd-ix.net:9324"
          ];
        }];
      }
      {
        job_name = "knot_exporter";
        static_configs = [{ targets = [ "ixp-as11201.dd-ix.net:9433" ]; }];
        metric_relabel_configs = [{
          source_labels = [ "__name__" ];
          regex = "knot_query_type_total";
          action = "keep";
        }];
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
