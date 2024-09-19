{ config, pkgs, ... }: {
  services = {
    pretix = {
      enable = true;
      package = pkgs.pretix;
      settings = {
        database = {
          name = "pretix";
          user = "pretix";
          host = "svc-pg01.dd-ix.net:5432";
          backend = "postgresql";
          createLocally = false; # we want to use the postgres vm
        };
        mail = {
          host = "svc-mta01.dd-ix.net";
          port = 25;
          from = "pretix@lists.dd-ix.net";
        };
      };
      nginx = {
        enable = true;
        domain = "tickets.${config.dd-ix.domain}";
      };
    };
  };
}
