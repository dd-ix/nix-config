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




      # We use Laravel's mail system - see: https://docs.ixpmanager.org/usage/email/
      # MAIL_MAILER="smtp"
      # MAIL_HOST="localhost"
      # MAIL_PORT=25
      # MAIL_ENCRYPTION=false

      IDENTITY_SITENAME = "DD-IX Portal";

      # Shown in title bar of web portal. Defaults to IDENTITY_SITENAME
      # IDENTITY_TITLENAME="Vagrant IXP Manager"

      IDENTITY_LEGALNAME = "DD-IX Dresden Internet Exchange e.V.";
      IDENTITY_CITY = "Dresden";
      IDENTITY_COUNTRY = "DE";
      #IDENTITY_ORGNAME="${IDENTITY_LEGALNAME}";

      # As well as uses in other places, emails are sent from the following name/email:
      #IDENTITY_NAME="${IDENTITY_LEGALNAME}";
      #IDENTITY_EMAIL="ixp@example.com"

      #IDENTITY_TESTEMAIL="${IDENTITY_EMAIL}"

      # Used on some traffic graphs:
      IDENTITY_WATERMARK = "DD-IX Dresden Internet Exchange e.V.";

      IDENTITY_SUPPORT_EMAIL = "noc@dd-ix.net";
      IDENTITY_SUPPORT_PHONE = "+49 351 41898230";
      IDENTITY_SUPPORT_HOURS = "24x7";

      IDENTITY_BILLING_EMAIL = "noc@dd-ix.net";
      IDENTITY_BILLING_PHONE = "+49 351 41898230";
      IDENTITY_BILLING_HOURS = "24x7";

      # Web address of your IXP's website. Used in IX-F Export schema, etc.
      IDENTITY_CORPORATE_URL = "http://dd-ix.net/";

      # The logo to show on the login page. Should be a URL.
      # (the example here works - the leading '//' means the browser should match http/https based on the web page)
      #IDENTITY_BIGLOGO="//www.ixpmanager.org/images/logos/ixp-manager.png";

      # For some actions (e.g. peering matrix) we need to know what VLAN to show by default.
      # This is the vlan.id database entry (i.e. not the VLAN number/tag!)
      #IDENTITY_DEFAULT_VLAN=1

    };
  };
}
