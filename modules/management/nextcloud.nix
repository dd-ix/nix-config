{ self, config, pkgs, lib, ... }:
let
  domain = "cloud.${config.dd-ix.domain}";
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

  sops.secrets."office_env" = {
    sopsFile = self + "/secrets/management/cloud.yaml";
    owner = "root";
  };

  systemd.services.nextcloud-setup.after = [ "network.target" ];

  services = {
    postgresql = {
      enable = lib.mkForce false;
      package = pkgs.postgresql_16;
    };
    nextcloud = {
      enable = true;
      hostName = domain;
      https = true;
      package = pkgs.nextcloud29;
      configureRedis = true;
      config = {
        dbtype = "pgsql";
        dbname = "nextcloud";
        dbhost = "svc-pg01.dd-ix.net";
        dbpassFile = "${config.sops.secrets."cloud_db_pw".path}";
        adminuser = "admin";
        adminpassFile = "${config.sops.secrets."cloud_admin_pw".path}";
      };
      settings = {
        allow_local_remote_servers = false;
        hide_login_form = true;
        mail_domain = "cloud.dd-ix.net";
        mail_from_address = "noreply";
        mail_smtpmode = "smtp";
        mail_smtphost = "svc-mta01.dd-ix.net";
        mail_smtpport = 25;
        mail_smtpsecure = ""; # ssl
        updatechecker = false;
        has_internet_connection = true;
        defaultapp = "files";
        appstoreenabled = true;
        overwriteprotocol = "https";
      };
      phpOptions = {
        "opcache.jit" = "tracing";
        "opcache.jit_buffer_size" = "100M";
        # recommended by nextcloud admin overview
        "opcache.interned_strings_buffer" = "16";
      };
      extraApps = {
        inherit (config.services.nextcloud.package.packages.apps) groupfolders polls user_oidc onlyoffice;
      };
      extraAppsEnable = true;
    };

    nginx.virtualHosts = {
      "cloud.${config.dd-ix.domain}" = {
        listen = [{
          addr = "[::]:443";
          proxyProtocol = true;
          ssl = true;
        }];

        onlySSL = true;
        useACMEHost = "cloud.${config.dd-ix.domain}";
      };
      "office.${config.dd-ix.domain}" = {
        listen = [{
          addr = "[::]:443";
          proxyProtocol = true;
          ssl = true;
        }];

        onlySSL = true;
        useACMEHost = "office.${config.dd-ix.domain}";
        locations."/" = {
          proxyPass = "http://127.0.0.1:80";
          proxyWebsockets = true;
        };
      };
    };
  };

  virtualisation.oci-containers.containers.onlyoffice = {
    image = "onlyoffice/documentserver:8.1.1.1";
    environmentFiles = [ config.sops.secrets."office_env".path ];
    extraOptions = [ "--network=host" ];
  };
}
