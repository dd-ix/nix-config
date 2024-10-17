{ self, config, lib, ... }:

let
  domain = "crm.${config.dd-ix.domain}";
in
{
  #  sops.secrets."openproject_env" = {
  #    sopsFile = self + "/secrets/management/crm.yaml";
  #    owner = "root";
  #  };

  services = {
    odoo = {
      enable = true;
      inherit domain;
      settings = { };
      addons = [ ];
    };

    # odoo module enables postgresql...
    postgresql.enable = lib.mkForce false;

    nginx = {
      enable = true;

      virtualHosts."${domain}" = {
        listen = [{
          addr = "[::]:443";
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
  };
}
