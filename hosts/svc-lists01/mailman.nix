{ self, config, lib, pkgs, ... }:

{
  sops.secrets."lists_db_pass" = {
    sopsFile = self + "/secrets/management/lists.yaml";
    owner = config.systemd.services.mailman.serviceConfig.User;
    group = config.systemd.services.mailman.serviceConfig.Group;
    mode = "0440";
  };

  sops.secrets."lists_web_db_pass" = {
    sopsFile = self + "/secrets/management/lists.yaml";
    owner = config.systemd.services.mailman.serviceConfig.User;
    group = config.systemd.services.mailman.serviceConfig.Group;
    mode = "0440";
  };

  sops.secrets."lists_oidc_client_secret" = {
    sopsFile = self + "/secrets/management/lists.yaml";
    owner = config.systemd.services.mailman.serviceConfig.User;
    group = config.systemd.services.mailman.serviceConfig.Group;
    mode = "0440";
  };

  sops.secrets."lists_env" = {
    sopsFile = self + "/secrets/management/lists.yaml";
    owner = config.systemd.services.mailman.serviceConfig.User;
    group = config.systemd.services.mailman.serviceConfig.Group;
    mode = "0440";
  };

  sops.secrets."lists_arc_priv_key" = {
    sopsFile = self + "/secrets/management/lists.yaml";
    owner = config.systemd.services.mailman.serviceConfig.User;
    group = config.systemd.services.mailman.serviceConfig.Group;
    mode = "0440";
  };

  sops.secrets."lists_rest_api_pass" = {
    sopsFile = self + "/secrets/management/lists.yaml";
    owner = config.systemd.services.mailman.serviceConfig.User;
    group = config.systemd.services.mailman.serviceConfig.Group;
    mode = "0440";
  };

  services.mailman = {
    enable = true;
    serve.enable = true;
    hyperkitty.enable = true;
    webHosts = [ "lists.dd-ix.net" ];
    siteOwner = "noc@dd-ix.net";
    enablePostfix = false;
    dbPassFile = config.sops.secrets."lists_db_pass".path;
    restApiPassFile = config.sops.secrets."lists_rest_api_pass".path;
    settings = {
      mta = {
        incoming = "mailman.mta.postfix.LMTP";
        outgoing = "mailman.mta.deliver.deliver";
        lmtp_host = /* svc-lists01.dd-ix.net */ "2a01:7700:80b0:6001::8";
        lmtp_port = "8024";
        smtp_host = "svc-mta01.dd-ix.net";
        smtp_port = "25";
        configuration = "${pkgs.writeText "mailman-postfix.cfg" /* ini */ ''
          [postfix]
          transport_file_type: regex
        ''}";
        remove_dkim_headers = "yes";
      };
      database = {
        class = "mailman.database.postgresql.PostgreSQLDatabase";
        url = "postgresql://mailman:#NIXOS_MAILMAN_DB_PW#@svc-pg01.dd-ix.net/mailman?sslmode=require";
      };
      ARC = {
        enabled = "yes";
        dmarc = "yes";
        dkim = "yes";
        authserv_id = "svc-mta01.dd-ix.net";
        privkey = config.sops.secrets."lists_arc_priv_key".path;
        # just take the current year
        selector = "arc_2024_2";
        domain = "lists.dd-ix.net";
      };
    };
    webSettings = {
      EMAIL_BACKEND = "django.core.mail.backends.smtp.EmailBackend";
      EMAIL_HOST = "svc-mta01.dd-ix.net";
      EMAIL_PORT = 25;
      DEFAULT_FROM_EMAIL = "noreply@lists.dd-ix.net";
      SERVER_EMAIL = "noreply@lists.dd-ix.net";
    };
  };

  systemd.services.mailman.serviceConfig.EnvironmentFile = config.sops.secrets."lists_env".path;

  environment.etc."mailman3/settings.py".text = lib.mkAfter /* python */ ''
    with open('${config.sops.secrets."lists_web_db_pass".path}') as f:
      DATABASES = {
        'default': {
          'ENGINE': 'django.db.backends.postgresql',
          'NAME': 'mailman_web',
          'USER': 'mailman_web',
          'PASSWORD': f.read(),
          'HOST': 'svc-pg01.dd-ix.net',
          'PORT': '5432',
        }
      }

    INSTALLED_APPS.append('allauth.socialaccount.providers.openid_connect')

    with open('${config.sops.secrets."lists_oidc_client_secret".path}') as f:
      SOCIALACCOUNT_PROVIDERS = {
        "openid_connect": {
          "APPS": [{
            "provider_id": "dd-ix-auth",
            "name": "DD-IX Auth",
            "client_id": "YmGymjU8CFStxNIiWMjnTsSgU46Nm4tVfBdkEZtM",
            "secret": f.read(),
            "settings": {
              "server_url": "https://auth.dd-ix.net/application/o/lists/",
            },
          }],
        }
      }
  '';

  services.nginx = {
    enable = true;
    virtualHosts."lists.${config.dd-ix.domain}" = {
      listen = [{
        addr = "[::]";
        port = 443;
        proxyProtocol = true;
        ssl = true;
      }];

      onlySSL = true;
      useACMEHost = "lists.${config.dd-ix.domain}";
    };
  };

  networking.firewall.allowedTCPPorts = [ 8024 ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "mailman3-exporter"
  ];

  services.prometheus.exporters.mailman3 = {
    enable = true;
    openFirewall = true;
    listenAddress = "::";
  };
}
