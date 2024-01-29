{ lib, config, ... }:
let
  cfg = config.dd-ix.fpx;
in
{
  options.dd-ix.fpx = lib.mkEnableOption (lib.mdDoc "dd-ix fpx");

  config = lib.mkif cfg {
    networking.proxy.default = "http://svc-fpx01.dd-ix.net:8080";
  };
}
