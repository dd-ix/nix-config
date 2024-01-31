{ lib, ... }:
{
  options.dd-ix.rpx = {
    domains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    addr = lib.mkOption {
      type = lib.types.str;
      default = null;
    };
  };
}
