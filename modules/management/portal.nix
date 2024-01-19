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
    environmentFile = config.sops.secrets."env_file".path;
    createDatabaseLocally = true;
    init = {
      adminUserName = "admin";
      adminEmail = "noc@dd-ix.net";
      adminPasswordFile = config.sops.secrets."admin_password".path;
      adminDisplayName = "Admin";
      ixpName = "Dresden Internet Exchange";
      ixpShortName = "DD-IX";
      ixpASN = 57328;
      ixpPeeringEmail = "peering@dd-ix.net";
      ixpNocPhone = "+49 351 41898230";
      ixpNocEmail = "noc@dd-ix.net";
      ixpWebsite = "https://dd-ix.net";
    };
    settings = {
      APP_URL = "https://portal.dd-ix.net";
      APP_CHIPHER = "aes-256-gcm";
    };
  };
}
