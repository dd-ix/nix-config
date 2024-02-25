{pkgs, config, lib, ...}: 
let
  cfg = config.dd-ix.monitoring;
in {
  options.dd-ix.monitoring = {
    enable = lib.mkEnableOption (lib.mdDoc "dd-ix monitoring");
    #name = lib.mkOption {
    #  type = lib.types.str;
    #};
  };

  config = lib.mkIf cfg.enable {
    services.prometheus.exporters = {
      node = {
	enable = true;
	port = 9100;
	listenAddress = "::";
	openFirewall = true;
	disabledCollectors = [];
	enabledCollectors = [];
      };
    };
  };
}
