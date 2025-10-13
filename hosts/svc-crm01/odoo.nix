{ self, lib, config, pkgs, ... }:

let
  domain = "crm.${config.dd-ix.domain}";
in
{
  sops.secrets."crm_db_pass" = {
    sopsFile = self + "/secrets/management/crm.yaml";
    owner = config.systemd.services.odoo.serviceConfig.User;
  };

  services = {
    odoo = {
      enable = true;
      inherit domain;
      package = pkgs.odoo.overrideAttrs {
        patches = [
          (pkgs.fetchpatch {
            url = "https://github.com/MarcelCoding/odoo/commit/7a5a8bf6467759973b3c864fb562099133c05e62.patch";
            hash = "sha256-YNbnn+oKRNEY0a4sFHRbp7QaN67fNsAYpt24ks8MOoI=";
          })
        ];
      };
      settings = {
        options = {
          #admin_passwd = "xxx";
          db_host = "svc-pg01.dd-ix.net";
          db_port = 5432;
          db_user = "odoo";
          db_password = "__file(${config.sops.secrets."crm_db_pass".path})";
          db_name = "odoo";
          db_sslmode = "verify-full";
        };
      };
      addons = [ ];
    };

    # odoo module enables postgresql...
    postgresql.enable = lib.mkForce false;

    nginx = {
      enable = true;

      virtualHosts."${domain}" = {
        listen = [{
          addr = "[::]";
          port = 443;
          proxyProtocol = true;
          ssl = true;
        }];

        onlySSL = true;
        useACMEHost = domain;
      };
    };
  };

  # odoo module configures postgresql as dependency...
  systemd.services.odoo = {
    after = lib.mkForce [ "network.target" ];
    requires = lib.mkForce [ ];

    # configure ssl for postgresql
    # https://www.dator.lu/blog/blog-1/odoo-16-0-and-postgresql-ssl-authentification-8
    environment = {
      # use system certificate store instead of some randong non-existstant one
      PGSSLROOTCERT = "system";
    };

    # reset dynamic user, as a manual static user is defined
    serviceConfig.DynamicUser = lib.mkForce false;
  };
}
