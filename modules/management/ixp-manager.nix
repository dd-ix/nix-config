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
    createDatabaseLocally = false;
    enableMRTG = true;

    nginx = {
      listen = [{
        addr = "[::]:443";
        proxyProtocol = true;
        ssl = true;
      }];

      onlySSL = true;
      useACMEHost = "portal.${config.dd-ix.domain}";

      # override hardcoded support page to just redirect to our own website
      locations."= /public-content/support".return = "302 https://dd-ix.net/contact";
    };

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

      DB_HOST = "svc-mari01.dd-ix.net";
      DB_DATABASE = "ixp_manager";
      DB_USERNAME = "ixp_manager";

      # We use Laravel's mail system - see: https://docs.ixpmanager.org/usage/email/
      MAIL_MAILER = "smtp";
      MAIL_HOST = "mta.dd-ix.net";
      MAIL_PORT = "25";
      MAIL_ENCRYPTION = "false";

      IDENTITY_SITENAME = "DD-IX Portal";

      # Shown in title bar of web portal. Defaults to IDENTITY_SITENAME
      # IDENTITY_TITLENAME="Vagrant IXP Manager"

      IDENTITY_LEGALNAME = "DD-IX Dresden Internet Exchange e.V.";
      IDENTITY_CITY = "Dresden";
      IDENTITY_COUNTRY = "DE";
      IDENTITY_ORGNAME = "\${IDENTITY_LEGALNAME}";

      # As well as uses in other places, emails are sent from the following name/email:
      IDENTITY_NAME = "DD-IX Dresden Internet Exchange";
      IDENTITY_EMAIL = "noreply@portal.dd-ix.net";

      #IDENTITY_TESTEMAIL="\${IDENTITY_EMAIL}";

      # Used on some traffic graphs:
      IDENTITY_WATERMARK = "DD-IX";

      IDENTITY_SUPPORT_EMAIL = "noc@dd-ix.net";
      IDENTITY_SUPPORT_PHONE = "+49 351 41898230";
      IDENTITY_SUPPORT_HOURS = "24x7";

      IDENTITY_BILLING_EMAIL = "noc@dd-ix.net";
      IDENTITY_BILLING_PHONE = "+49 351 41898230";
      IDENTITY_BILLING_HOURS = "24x7";

      # Web address of your IXP's website. Used in IX-F Export schema, etc.
      IDENTITY_CORPORATE_URL = "https://dd-ix.net/";

      # The logo to show on the login page. Should be a URL.
      # (the example here works - the leading '//' means the browser should match http/https based on the web page)
      IDENTITY_BIGLOGO = "https://dd-ix.net/assets/images/logo.svg";

      # For some actions (e.g. peering matrix) we need to know what VLAN to show by default.
      # This is the vlan.id database entry (i.e. not the VLAN number/tag!)
      IDENTITY_DEFAULT_VLAN = "1";

      # See: http://docs.ixpmanager.org/features/reseller/
      IXP_RESELLER_ENABLED = "false";

      # See: http://docs.ixpmanager.org/features/as112/
      IXP_AS112_UI_ACTIVE = "false";

      # Send email notifications when a customer's billing details are updated.
      # See: http://docs.ixpmanager.org/usage/customers/#notification-of-billing-details-changed
      IXP_FE_CUSTOMER_BILLING_UPDATES_NOTIFY = "vorstand@dd-ix.net";

      # AUTH_PEERINGDB_ENABLED=true;
      # PEERINGDB_OAUTH_CLIENT_ID="xxx";
      # PEERINGDB_OAUTH_CLIENT_SECRET="xxx";
      # PEERINGDB_OAUTH_REDIRECT="https://www.example.com/auth/login/peeringdb/callback";
    };
  };
}
