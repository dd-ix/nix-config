{ config, pkgs, ... }:
let
  domain = "netbox.dd-ix.net";
in
{
  sops.secrets.netbox_db_pass.owner = "netbox";
  sops.secrets.netbox_secret_key_file.owner = "netbox";


  services.postgresql = {
    enable = true;
    ensureUsers = [
      {
        name = "netbox";
        ensurePermissions = {
          "DATABASE netbox" = "ALL PRIVILEGES";
        };
      }
    ];
    ensureDatabases = [ "netbox" ];
  };

  services.netbox = {
    enable = true;
    package = pkgs.netbox;
    port = 9502;
    listenAddress = "127.0.0.1";
    secretKeyFile = "${config.sops.secrets.netbox_secret_key_file.path}";

  };

  services.nginx.virtualHosts."netbox.dd-ix.net".locations."/".proxyPass = "http://127.0.0.1:9502";
  services.nginx.virtualHosts."netbox.dd-ix.net".forceSSL = true;
  services.nginx.virtualHosts."netbox.dd-ix.net".enableACME = true;

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
