{ self, lib, config, ... }:
let
  cfg = config.dd-ix.acme;
in
{
  options.dd-ix.postgres = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
  };
}
