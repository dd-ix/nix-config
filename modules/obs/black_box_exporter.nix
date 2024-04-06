{ pkgs, config, lib, ... }: {

  services.prometheus.exporters.blackbox = {
    enable = true;
    openFirewall = true;
    port = 9115;
    configFile = ../../resources/blackbox-exporter.yaml;
  };

}


