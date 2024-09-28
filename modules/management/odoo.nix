{ self, config, lib, ... }:

let
  domain = "crm.${config.dd-ix.domain}";
in
{
  #  sops.secrets."openproject_env" = {
  #    sopsFile = self + "/secrets/management/crm.yaml";
  #    owner = "root";
  #  };

  nixpkgs.config.permittedInsecurePackages = [
    "qtwebkit-5.212.0-alpha4"
  ];

  services = {
    odoo = {
      enable = true;
      inherit domain;
      settings = { };
    };

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
}
