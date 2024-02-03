{ self, config, pkgs, ... }:
let
  domain = "cloud.${config.deployment-dd-ix.domain}";
in
{
  sops.secrets."cloud_admin_pw" = {
    sopsFile = self + "/secrets/management/cloud.yaml";
    owner = config.systemd.services.nextcloud-setup.serviceConfig.User;
  };

  sops.secrets."cloud_db_pw" = {
    sopsFile = self + "/secrets/management/cloud.yaml";
    owner = config.systemd.services.nextcloud-setup.serviceConfig.User;
  };

  systemd.services.nextcloud-setup.after = [ "network.target" ];

  services.nextcloud = {
    enable = true;
    hostName = domain;
    https = true;
    package = pkgs.nextcloud28;
    configureRedis = true;
    config = {
      dbtype = "pgsql";
      dbname = "nextcloud";
      dbhost = "svc-pg01.dd-ix.net";
      dbpassFile = "${config.sops.secrets."cloud_db_pw".path}";
      overwriteProtocol = "https";
      adminuser = "admin";
      adminpassFile = "${config.sops.secrets."cloud_admin_pw".path}";
    };
    extraOptions = {
      allow_local_remote_servers = true;
      hide_login_form = true;
      mail_domain = "cloud.dd-ix.net";
      mail_from_address = "noreply";
      mail_smtpmode = "smtp";
      mail_smtphost = "mta.dd-ix.net";
      mail_smtpport = 25;
      mail_smtpsecure = ""; # ssl
      updatechecker = false;
      has_internet_connection = false;
      defaultapp = "files";
      appstoreenabled = false;
    };
    phpOptions = {
      "opcache.jit" = "tracing";
      "opcache.jit_buffer_size" = "100M";
      # recommended by nextcloud admin overview
      "opcache.interned_strings_buffer" = "16";
    };
    extraApps = {
      inherit (config.services.nextcloud.package.packages.apps) groupfolders polls user_oidc;
    };
    extraAppsEnable = true;
  };

  services.nginx.virtualHosts."cloud.${config.deployment-dd-ix.domain}" = {
    listen = [{
      addr = "[::]:443";
      proxyProtocol = true;
      ssl = true;
    }];

    onlySSL = true;
    useACMEHost = "cloud.${config.deployment-dd-ix.domain}";
  };
}
