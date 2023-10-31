{ config, pkgs, ... }:
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
        ensurePermissions = {
          "DATABASE nextcloud" = "ALL PRIVILEGES";
        };
      }
    ];
    ensureDatabases = [ "nextcloud" ];
  };

  services.nextcloud = {
    enable = true;
    hostName = domain;
    https = true;
    package = pkgs.nextcloud27;
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
    extraAppsEnable = true;
  };

  services.nginx.virtualHosts."cloud.${config.deployment-dd-ix.domain}".forceSSL = true;
  services.nginx.virtualHosts."cloud.${config.deployment-dd-ix.domain}".enableACME = true;

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
