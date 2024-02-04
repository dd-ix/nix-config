{ lib, config, ... }:
let
  cfg = config.dd-ix.useFpx;
in
{
  options.dd-ix.useFpx = lib.mkEnableOption (lib.mdDoc "dd-ix fpx");

  config = lib.mkIf cfg {
    networking.proxy = {
      default = "http://svc-fpx01.dd-ix.net:8080";
      noProxy = "127.0.0.1/8,::1,2a01:7700:80b0::/48,localhost,dd-ix.net";
    };
    environment.sessionVariables = config.networking.proxy.envVars;
  };
}
