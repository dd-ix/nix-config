{ self, config, pkgs, lib, ... }:

let
  domain = "cloud.${config.dd-ix.domain}";
in
{
  sops.secrets = {
    "cloud_admin_pw" = {
      sopsFile = self + "/secrets/management/cloud.yaml";
      owner = config.systemd.services.nextcloud-setup.serviceConfig.User;
    };

    "cloud_db_pw" = {
      sopsFile = self + "/secrets/management/cloud.yaml";
      owner = config.systemd.services.nextcloud-setup.serviceConfig.User;
    };
  };

  systemd.services.nextcloud-setup.after = [ "network.target" ];

  services = {
    postgresql = {
      enable = lib.mkForce false;
    };
    nextcloud = {
      enable = true;
      hostName = domain;
      https = true;
      package = pkgs.nextcloud31;
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
        #loglevel = 0;
      };
      phpOptions = {
        "opcache.jit" = "tracing";
        "opcache.jit_buffer_size" = "100M";
        # recommended by nextcloud admin overview
        "opcache.interned_strings_buffer" = "16";
      };
      extraApps = {
        inherit (config.services.nextcloud.package.packages.apps) groupfolders polls user_oidc richdocuments forms;
      };
      extraAppsEnable = true;
      # NixOS Modules
      #configureImaginary = true;
    };

    nginx.virtualHosts = {
      "cloud.${config.dd-ix.domain}" = {
        listen = [
          {
            addr = "[::]:443";
            proxyProtocol = true;
            ssl = true;
          }
          {
            addr = "[::1]:443";
            ssl = true;
          }
        ];

        onlySSL = true;
        useACMEHost = "cloud.${config.dd-ix.domain}";
      };
      "office.${config.dd-ix.domain}" = {
        listen = [
          {
            addr = "[::]:443";
            proxyProtocol = true;
            ssl = true;
          }
          {
            addr = "[::1]:443";
            ssl = true;
          }
          {
            addr = "127.0.0.1:443";
            ssl = true;
          }
        ];

        onlySSL = true;
        useACMEHost = "office.${config.dd-ix.domain}";
        locations."/" = {
          proxyPass = "http://[::1]:${builtins.toString config.services.collabora-online.port}";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_read_timeout 36000s;
          '';
        };
      };
    };

    collabora-online = {
      enable = true;

      aliasGroups = [{
        host = "https://office.${config.dd-ix.domain}";
        aliases = [ "https://${config.services.nextcloud.hostName}" ];
      }];

      settings = {
        # Rely on reverse proxy for SSL
        ssl = {
          enable = false;
          termination = true;
        };
      };
    };
  };
}
