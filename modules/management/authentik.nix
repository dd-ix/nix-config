{ self, config, pkgs, inputs, ... }:
let
  hostname = "auth.${config.deployment-dd-ix.domain}";

  customScope = (inputs.authentik.lib.mkAuthentikScope { inherit pkgs; }).overrideScope
    (final: prev: prev.authentikComponents // {
      frontend = prev.authentikComponents.frontend.overrideAttrs (_: {
        patches = [ (self + /resouces/authentik-logo.pathc) ];
      });
    });
in
{
  sops.secrets."authentik_env" = {
    sopsFile = self + "/secrets/management/auth.yaml";
  };

  sops.secrets."authentik_radius_env" = {
    sopsFile = self + "/secrets/management/auth.yaml";
  };

  systemd.services.authentik-worker.serviceConfig. LoadCredential = [
    "${hostname}.pem:${config.security.acme.certs."${hostname}".directory}/fullchain.pem"
    "${hostname}.key:${config.security.acme.certs."${hostname}".directory}/key.pem"
  ];

  services.nginx = {
    enable = true;
    virtualHosts."cloud.${config.deployment-dd-ix.domain}" = {
      listen = [{
        addr = "[::]:443";
        proxyProtocol = true;
        ssl = true;
      }];

      onlySSL = true;
      useACMEHost = hostname;

      locations."/" = {
        proxyWebsockets = true;
        proxyPass = "http://[::1]:9000";
      };
    };
  };

  services = {
    authentik = {
      inherit (customScope) authentikComponents;

      enable = true;

      environmentFile = config.sops.secrets."authentik_env".path;

      createDatabase = false;

      settings = {
        postgresql = {
          host = "svc-pg01.dd-ix.net";
          name = "authentik";
          user = "authentik";
        };
        email = {
          host = "mta.dd-ix.net";
          port = 25;
          username = "";
          use_tls = false;
          use_ssl = false;
          from = "noreply@auth.dd-ix.net";
          template_dir = self + "/resources/authentik";
        };
        cookie_domain = "auth.dd-ix.net";
        disable_startup_analytics = true;
        avatars = "initials";
        footer_links = "[{\"name\":\"Imprint\",\"href\":\"https://dd-ix.net/imprint\"},{\"name\":\"Privacy Policy\",\"href\":\"https://dd-ix.net/privacy-policy\"}]";
        cert_discovery_dir = "env://CREDENTIALS_DIRECTORY";
      };
    };
    authentik-radius = {
      enable = true;
      environmentFile = config.sops.secrets."authentik_radius_env".path;
    };
  };
}
