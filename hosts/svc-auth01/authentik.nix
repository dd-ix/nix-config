{
  self,
  config,
  pkgs,
  ...
}:
let
  hostname = "auth.${config.dd-ix.domain}";

  customScope = (self.inputs.authentik.lib.mkAuthentikScope { inherit pkgs; }).overrideScope (
    _: prev:
    prev.authentikComponents
    // {
      frontend = prev.authentikComponents.frontend.overrideAttrs (_: {
        patches = [ (self + /resouces/authentik-logo.patch) ];
      });
    }
  );
in
{
  sops.secrets = {
    "authentik/env".sopsFile = self + "/secrets/management/auth.yaml";
    "authentik/radius_env".sopsFile = self + "/secrets/management/auth.yaml";
    "authentik/proxy_env".sopsFile = self + "/secrets/management/auth.yaml";
  };

  systemd.services.authentik-worker.serviceConfig.LoadCredential = [
    "${hostname}.pem:${config.security.acme.certs."${hostname}".directory}/fullchain.pem"
    "${hostname}.key:${config.security.acme.certs."${hostname}".directory}/key.pem"
  ];

  services.nginx = {
    enable = true;
    virtualHosts."auth.${config.dd-ix.domain}" = {
      listen = [
        {
          addr = "[::]";
          port = 443;
          proxyProtocol = true;
          ssl = true;
        }
      ];

      onlySSL = true;
      useACMEHost = hostname;

      locations = {
        "/" = {
          proxyWebsockets = true;
          proxyPass = "http://[::1]:9000";
        };
        "/outpost.goauthentik.io" = {
          recommendedProxySettings = false;
          extraConfig = /* nginx */ ''
            proxy_pass http://${config.services.authentik-proxy.listenHTTP}/outpost.goauthentik.io;
            proxy_set_header        Host $host;
            proxy_set_header        X-Real-IP $remote_addr;
            proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header        X-Forwarded-Proto $scheme;
          '';
        };
      };
    };
  };

  services = {
    authentik = {
      inherit (customScope) authentikComponents;

      enable = true;

      environmentFile = config.sops.secrets."authentik/env".path;

      createDatabase = false;

      settings = {
        postgresql = {
          host = "svc-pg01.dd-ix.net";
          name = "authentik";
          user = "authentik";
          sslmode = "verify-full";
          sslrootcert = builtins.fetchurl {
            url = "https://letsencrypt.org/certs/isrgrootx1.pem";
            sha256 = "sha256:1la36n2f31j9s03v847ig6ny9lr875q3g7smnq33dcsmf2i5gd92";
          };
        };
        email = {
          host = "svc-mta01.dd-ix.net";
          port = 25;
          username = "";
          use_tls = false;
          use_ssl = true;
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
      environmentFile = config.sops.secrets."authentik/radius_env".path;
    };
    authentik-proxy = {
      enable = true;
      environmentFile = config.sops.secrets."authentik/proxy_env".path;
    };
  };

  systemd.services.authentik.environment = {
    AUTHENTIK_ERROR_REPORTING__ENABLED = "false";
    AUTHENTIK_DISABLE_UPDATE_CHECK = "true";
    AUTHENTIK_DISABLE_STARTUP_ANALYTICS = "true";
    AUTHENTIK_AVATARS = "initials";
  };
}
