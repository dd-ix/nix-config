{ config, pkgs, lib, ... }:

let
  domain = "cloud.${config.dd-ix.domain}";
in
{
  sops.secrets = {
    "nextcloud/admin_pass" = { };
    "nextcloud/db_pass" = { };
  };

  systemd.services = {
    nextcloud-setup.after = [ "network.target" ];
    nextcloud-update-db.after = [ "network.target" ];
  };

  services = {
    postgresql.enable = lib.mkForce false;
    nextcloud = {
      enable = true;
      package = pkgs.nextcloud31;
      hostName = domain;
      https = true;
      config = {
        dbtype = "pgsql";
        dbname = "nextcloud";
        dbhost = "svc-pg01.dd-ix.net";
        dbuser = "nextcloud";
        dbpassFile = "${config.sops.secrets."nextcloud/db_pass".path}";
        adminuser = "admin";
        adminpassFile = "${config.sops.secrets."nextcloud/admin_pass".path}";
      };
      settings = {
        default_phone_region = "DE";
        maintenance_window_start = "4";
        allow_local_remote_servers = false;
        hide_login_form = true;
        mail_domain = "cloud.dd-ix.net";
        mail_from_address = "noreply";
        mail_smtpmode = "smtp";
        mail_smtphost = "svc-mta01.dd-ix.net";
        mail_smtpport = 25;
        mail_smtpsecure = ""; # ssl
        has_internet_connection = true;
        defaultapp = "files";
        appstoreenabled = true;
        overwriteprotocol = "https";
        #loglevel = 0;
      };
      phpOptions = {
        # recommended by nextcloud admin overview
        "opcache.interned_strings_buffer" = 16; # default 8
        # https://docs.nextcloud.com/server/24/admin_manual/installation/server_tuning.html#enable-php-opcache
        "opcache.revalidate_freq" = 60; # default 1
        # https://docs.nextcloud.com/server/latest/admin_manual/installation/server_tuning.html#:~:text=opcache.jit%20%3D%201255%20opcache.jit_buffer_size%20%3D%20128m
        "opcache.jit" = 1255;
        "opcache.jit_buffer_size" = "128M";
      };
      extraApps = {
        inherit (config.services.nextcloud.package.packages.apps)
          groupfolders polls user_oidc forms;
      };
      extraAppsEnable = true;
    };

    nginx.virtualHosts."cloud.${config.dd-ix.domain}" = {
      listen = [
        {
          addr = "[::]";
          port = 443;
          proxyProtocol = true;
          ssl = true;
        }
        {
          addr = "[::1]";
          port = 443;
          ssl = true;
        }
      ];

      onlySSL = true;
      useACMEHost = config.services.nextcloud.hostName;
    };
  };
}
