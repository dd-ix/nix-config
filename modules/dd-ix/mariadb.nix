{ lib, ... }:
{
  options.dd-ix.mariadb = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
  };
}
