{ pkgs, config, lib, ... }: {

  services.prometheus.exporters.blackbox = {
    enable = true;
    openFirewall = true;
    port = 9115;
  };

}


