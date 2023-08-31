{ pkgs, config, ... }: {
  services = {
    listmonk = {
      enable = true;
      settings = {
        app = {
          address = "127.0.0.1:9820";
        };
      };
      database = {
        createLocally = true;
        settings = {
          smtp = [
            {
              enable = true;
              host = "127.0.0.1";
              port = 9821;
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
