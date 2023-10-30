{ lib, ... }:
with lib; {
  options = {
    deployment-dd-ix.systemNumber = mkOption {
      type = types.int;
      default = 0;
      description = "number of the system";
    };

    deployment-dd-ix.domain = mkOption {
      type = types.str;
      default = "dd-ix.net";
      description = "domain the server is running on";
    };
  };
}


