{ config, pkgs, options, ... }:
let
  domain = "cloud.${config.deployment-dd-ix.domain}";
in
{
  sops.secrets.nextcloud_db_pass.owner = "nextcloud";
  sops.secrets.nextcloud_admin_pass.owner = "nextcloud";

  services.postgresql = {
    enable = true;
    ensureUsers = [
      {
        name = "nextcloud";
        ensureDBOwnership = true;
      }
    ];
    ensureDatabases = [ "nextcloud" ];
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
      dbhost = "/run/postgresql";
      dbpassFile = "${config.sops.secrets.nextcloud_db_pass.path}";
      overwriteProtocol = "https";
      adminuser = "admin";
      adminpassFile = "${config.sops.secrets.nextcloud_admin_pass.path}";
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

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
