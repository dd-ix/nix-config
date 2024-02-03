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
