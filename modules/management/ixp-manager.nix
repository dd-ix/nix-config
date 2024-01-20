{ self, config, ... }:
{
  sops.secrets."admin_password" = {
    owner = config.services.ixp-manager.user;
    sopsFile = self + "/secrets/management/portal.yaml";
  };

  sops.secrets."env_file" = {
    owner = config.services.ixp-manager.user;
    sopsFile = self + "/secrets/management/portal.yaml";
  };

  services.ixp-manager = {
    enable = true;
    hostname = "portal.dd-ix.net";
    #environmentFile = config.sops.secrets."env_file".path;
    createDatabaseLocally = true;
    init = {
      admin = {
        userName = "admin";
        email = "noc@dd-ix.net";
        passwordFile = config.sops.secrets."admin_password".path;
        displayName = "Admin";
      };
      ixp = {
        name = "Dresden Internet Exchange";
        shortName = "DD-IX";
        asn = 57328;
        peeringEmail = "peering@dd-ix.net";
        noc = {
          phone = "+49 351 41898230";
          email = "noc@dd-ix.net";
        };
        website = "https://dd-ix.net";
      };
    };
    settings = {
      APP_URL = "https://portal.dd-ix.net";
      APP_CHIPHER = "aes-256-gcm";
      DB_PASSWORD = "test";
    };
  };
}
