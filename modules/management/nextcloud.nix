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
    };
    nextcloud = {
      enable = true;
      hostName = domain;
      https = true;
      package = pkgs.nextcloud30;
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
      # NixOS Modules
      configureImaginary = true;
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

  # nix-prefetch-docker --image-name onlyoffice/documentserver --image-tag 8.2.0.1
  virtualisation.oci-containers.containers.onlyoffice = {
    image = "onlyoffice/documentserver:8.2.2.1";
    imageFile = pkgs.dockerTools.pullImage {
      imageName = "onlyoffice/documentserver";
      imageDigest = "sha256:3489a54c581414055dd9bfa3890435e5e6fc8c4ce0ffdd65cf3c7869f680cf81";
      sha256 = "1sjdb99a13y1m8k3awnf5cqy3r18kjs8k6b3vd8bn64yvkhdgxhp";
      finalImageName = "onlyoffice/documentserver";
      finalImageTag = "8.2.2.1";
    };
    environmentFiles = [ config.sops.secrets."office_env".path ];
    extraOptions = [ "--network=host" ];
  };

  # enable when exists in nixos-modules
  #virtualisation.podman.aggresiveAutoPrune = true;
}
