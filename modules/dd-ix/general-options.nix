{ lib, ... }:
with lib; {
  options = {
    deployment-dd-ix.domain = mkOption {
      type = types.str;
      default = "dd-ix.net";
      description = "domain the server is running on";
    };
  };
}


