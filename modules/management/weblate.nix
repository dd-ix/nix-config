{ self, lib, config, pkgs, ... }:

{
  #   nixpkgs.overlays = [
  #     (_: prev: {
  #       pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
  #         (_: python-prev: {
  #           pyjwt = python-prev.pyjwt.overridePythonAttrs (_: {
  #             doCheck = false;
  #             patches = [
  #               (pkgs.fetchpatch {
  #                 url = "https://github.com/jpadilla/pyjwt/commit/0ab0c02735ab42e1f1cc2ac1e5c80a0273f691f0.patch";
  #                 hash = "sha256-HEFjltt76rcXbPOgkxsSTfY66Oq7no0MQDay2FcoHqY=";
  #               })
  #             ];
  #           });
  #         })
  #       ];
  #     })
  #   ];

  sops.secrets = {
    "weblate/django_secret_key" = {
      sopsFile = self + /secrets/management/translate.yaml;
      owner = config.systemd.services.weblate.serviceConfig.User;
    };
    "weblate/db_pass" = {
      sopsFile = self + /secrets/management/translate.yaml;
      owner = config.systemd.services.weblate.serviceConfig.User;
    };
    "weblate/oidc_client_secret" = {
      sopsFile = self + /secrets/management/translate.yaml;
      owner = config.systemd.services.weblate.serviceConfig.User;
    };
  };

  systemd.services.weblate-postgresql-setup.serviceConfig = {
    ExecStart = lib.mkForce (lib.getExe' pkgs.coreutils "true");
    User = lib.mkForce "nobody";
    Group = lib.mkForce "nobody";
  };

  services = {
    weblate = {
      enable = true;
      localDomain = "translate.${config.dd-ix.domain}";
      djangoSecretKeyFile = config.sops.secrets."weblate/django_secret_key".path;
      smtp = {
        enable = true;
        host = "svc-mta01.dd-ix.net";
        from = "noreply@translate.dd-ix.net";
      };
      extraConfig = /* python */ ''
        SITE_TITLE = "DD-IX Translate"

        with open("${config.sops.secrets."weblate/db_pass".path}") as f:
          DATABASES = {
            "default": {
              "ENGINE": "django.db.backends.postgresql",
              "NAME": "weblate",
              "USER": "weblate",
              "PASSWORD": f.read().rstrip("\n"),
              "HOST": "svc-pg01.dd-ix.net",
              "PORT": "5432",
              "CONN_MAX_AGE": None,
              "CONN_HEALTH_CHECKS": True,
            }
          }

        AUTHENTICATION_BACKENDS = (
          "social_core.backends.open_id_connect.OpenIdConnectAuth",
          "weblate.accounts.auth.WeblateUserBackend",
        )

        SOCIAL_AUTH_OIDC_OIDC_ENDPOINT = "https://auth.dd-ix.net/application/o/translate/"
        SOCIAL_AUTH_OIDC_KEY = "Oro3Hr3zWRlTDLYc5mfUZK3chTBPbOLNymXSmABN"
        with open("${config.sops.secrets."weblate/oidc_client_secret".path}") as f:
          SOCIAL_AUTH_OIDC_SECRET = f.read().rstrip("\n")
        #SOCIAL_AUTH_OIDC_IMAGE = "https://dd-ix.net/en/assets/images/logo.svg"
        SOCIAL_AUTH_OIDC_TITLE = "DD-IX Auth"

        DEFAULT_COMMITER_EMAIL = "noreply@translate.dd-ix.net"
        DEFAULT_COMMITER_NAME = "DD-IX Translate"
      '';
    };
    nginx.virtualHosts. "translate.${config.dd-ix.domain}" = {
      listen = [{
        addr = "[::]:443";
        proxyProtocol = true;
        ssl = true;
      }];

      onlySSL = true;
      useACMEHost = "translate.${config.dd-ix.domain}";

      forceSSL = lib.mkForce false;
      enableACME = lib.mkForce false;
    };
  };

  # don't use the local database, we have svc-pg01.dd-ix.net
  services.postgresql.enable = lib.mkForce false;
}
