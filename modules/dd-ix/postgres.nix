{ lib, ... }:
{
  options.dd-ix.postgres = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
  };
}
