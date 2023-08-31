{ pkgs, config, ... }: {

  sops.secrets.listmonk.owner = "netbox";
  services = {
    listmonk = {
      enable = true;
      settings = {
        app = {
          address = "127.0.0.1:9820";
          admin_username = "admin";
        };
      };
      secretFile = config.sops.secrets.listmonk.path;
      database = {
        createLocally = true;
        settings = {
          smtp = [
            {
              enabled = true;
              host = "smtp.migadu.com";
              port = 465;
              tls_type = "TLS";
            }
          ];
          "privacy.domain_blocklist" = [ ]; # list of domains excluded from subscribing
          "app.notify_emails" = [ "admin@dd-ix.net" ];
        };
      };
    };
    nginx = {
      enable = true;
      virtualHosts."lists.dd-ix.net" = {
        locations =
          let
            cfg = config.services.listmonk.settings;
          in
          {
            "/".proxyPass = "http://${cfg.app.address}";
          };
        forceSSL = true;
        enableACME = true;
      };
    };
  };
}
