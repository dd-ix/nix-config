{ self, config, lib, ... }:
let
  toList = attrs: (builtins.map (key: lib.getAttr key attrs) (lib.attrNames attrs));

  # list of all nixos systems in this flake
  allSystems = toList self.nixosConfigurations;
in
{
  services.prometheus = {
    enable = true;
    retentionTime = "90d";
    webExternalUrl = "https://svc-prom01.dd-ix.net";
    scrapeConfigs = [
      {
        job_name = "node_exporter";
        static_configs = [{
          targets =
            let
              # filters out all the systems where monitoring is turned off
              monitoredSystems = builtins.filter (x: x.config.dd-ix.monitoring.enable == true) allSystems;

              # turns the hostname into an address
              extractAddress = host: "${host.config.dd-ix.hostName}.dd-ix.net:9100";

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
        job_name = "smart_exporter";
        static_configs = [{
          targets =
            let
              # filters out all the systems where monitoring is turned off
              monitoredSystems = builtins.filter (x: x.config.dd-ix.monitoring.smart.enable == true) allSystems;

              # turns the hostname into an address
              extractAddress = host: "${host.config.dd-ix.monitoring.smart.host}:${toString host.config.dd-ix.monitoring.smart.port}";

              # list of addresses
              listAddress = builtins.map extractAddress monitoredSystems;

            in
            listAddress;
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
        job_name = "blackbox";
        metrics_path = "/probe";
        params = {
          module = [ "http_2xx" ];
        };
        relabel_configs = [
          {
            source_labels = [ "__address__" ];
            target_label = "__param_target";
          }
          {
            source_labels = [ "__param_target" ];
            target_label = "instance";
          }
          {
            target_label = "__address__";
            replacement = "svc-bbe01.dd-ix.net:9115";
          }
        ];
        static_configs = [{
          targets = [
            "https://dd-ix.net/en/"
            "https://cloud.dd-ix.net/status.php"
            "https://dcim.dd-ix.net/api/"
            "https://lg.dd-ix.net"
            "https://portal.dd-ix.net/login"
            "https://wiki.dd-ix.net/status"
            "https://auth.dd-ix.net/-/health/ready/"
          ];
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
