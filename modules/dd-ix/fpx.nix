{ lib, config, ... }:
let
  cfg = config.dd-ix.useFpx;
in
{
  options.dd-ix.useFpx = lib.mkEnableOption (lib.mdDoc "dd-ix fpx");

  config = lib.mkIf cfg {
    networking.proxy.default = "http://svc-fpx01.dd-ix.net:8080";
  };
}
