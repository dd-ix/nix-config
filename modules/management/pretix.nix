{ config, pkgs, ... }:
let
  database_name = "pretix";
  username = "pretix";
in
{
  services = {
    pretix = {
      enable = true;
      package = pkgs.pretix;
      settings = {
        database = {
          name = database_name;
          user = username;
        };
      };
      database = {
        createLocally = true;
      };
      nginx = {
        enable = true;
        domain = "tickets.${config.dd-ix.domain}";
      };
    };
  };
}
