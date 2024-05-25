{ lib, options, config, ... }:
{
  options = {
    dd-ix = {
      hostName = options.networking.hostName;
      domain = lib.mkOption {
        type = lib.types.str;
      };
    };
  };
  config = {
    networking = {
      hostName = config.dd-ix.hostName;
      domain = "dd-ix.net";
    };
    dd-ix.domain = "dd-ix.net";
  };
}


