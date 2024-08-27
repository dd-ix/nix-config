{pkgs, config, lib, ...}: {
  services = {
    odoo = {
      enable = true;
      domain = "crm.${config.dd-ix.domain}";
      settings = {
        db_user = "odoo";
      };
    };
    nginx = {
      enable = true;
      virtualhosts."crm.${config.dd-ix.domain}" =  {
        onlySSL = true;
        location = {
          "/longpolling" = {
            proxyPass = "/odoochat";
          };
          "/" = {
            proxyPass = "/oddo";
          };
        };
      };
    };
  };
}
