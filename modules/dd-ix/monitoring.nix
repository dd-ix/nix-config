{ config, lib, ... }:

let
  cfg = config.dd-ix.monitoring;
in
{
  options.dd-ix.monitoring = {
    enable = lib.mkEnableOption (lib.mdDoc "dd-ix monitoring");
    smart = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };

      devices = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.prometheus.exporters = {
      node = {
        enable = true;
        port = 9100;
        listenAddress = "[::]";
        openFirewall = true;
        disabledCollectors = [ ];
        enabledCollectors = [ "systemd" ];
      };
      smartctl = lib.mkIf cfg.smart.enable {
        enable = true;
        maxInterval = "10m";
        listenAddress = "[::1]";
        openFirewall = true;
        port = 9101;
        inherit (cfg.smart) devices;
      };
    };
  };
}
