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
	listenAddress = (builtins.elemAt (builtins.split "/" config.dd-ix.microvm.v6Addr) 0); # removing cidr
	openFirewall = true;
	disabledCollectors = [];
	enabledCollectors = [];
      };
    };
  };
}
