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

  /*  services.postfix = {
    enable = true;
    relayDomains = [ "hash:/var/lib/mailman/data/postfix_domains" ];
    sslCert = config.security.acme.certs."lists.example.org".directory + "/full.pem";
    sslKey = config.security.acme.certs."lists.example.org".directory + "/key.pem";
    config = {
      transport_maps = [ "hash:/var/lib/mailman/data/postfix_lmtp" ];
      local_recipient_maps = [ "hash:/var/lib/mailman/data/postfix_lmtp" ];
    };
  };*/
  services.mailman = {
    enable = true;
    serve.enable = true;
    hyperkitty.enable = true;
    webHosts = [ "lists.dd-ix.net" ];
    siteOwner = "noc@dd-ix.net";
    enablePostfix = false;
    #extraPythonPackages = with pkgs.python3Packages; [ psycopg2 ];
    settings = {
      mta = {
        incoming = "mailman.mta.postfix.LMTP";
        outgoing = "mailman.mta.deliver.deliver";
        lmtp_host = /* svc-lists01.dd-ix.net */ "2a01:7700:80b0:6001::8";
        lmtp_port = "8024";
        smtp_host = "mta.dd-ix.net";
        smtp_port = "25";
        configuration = "${pkgs.writeText "mailman-postfix.cfg" /* ini */ ''
          [postfix]
          transport_file_type: regex
        ''}";
      };
      database = {
        class = "mailman.database.postgresql.PostgreSQLDatabase";
      };
    };
    webSettings = {
      EMAIL_BACKEND = "django.core.mail.backends.smtp.EmailBackend";
      EMAIL_HOST = "mta.dd-ix.net";
      EMAIL_PORT = 25;
      DEFAULT_FROM_EMAIL = "noreply@lists.dd-ix.net";
      SERVER_EMAIL = "noreply@lists.dd-ix.net";
    };
  };

  environment.etc."mailman3/settings.py".text = lib.mkAfter /* python */ ''
    import urllib.parse
    with open('${config.sops.secrets."lists_db_pass".path}') as f:
      config['database']['url'] = f"postgresql://mailman:{urllib.parse.quote(f.read())}@svc-pg01.dd-ix.net/mailman?sslmode=require"
    
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
  '';

  services.nginx = {
    enable = true;
    virtualHosts."lists.${config.dd-ix.domain}" = {
      listen = [{
        addr = "[::]:443";
        proxyProtocol = true;
        ssl = true;
      }];

      onlySSL = true;
      useACMEHost = "lists.${config.dd-ix.domain}";
    };
  };
}