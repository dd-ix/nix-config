{ self, config, pkgs, ... }: {

  sops.secrets.web_listmonk_admin_pw = {
    sopsFile = self + "/secrets/management/web.yaml";
    owner = "root";
  };

  services.nginx = {
    enable = true;
    virtualHosts = {
      "www.${config.deployment-dd-ix.domain}" = {
        listen = [{
          addr = "[::]:443";
          proxyProtocol = true;
          ssl = true;
        }];

        onlySSL = true;
        useACMEHost = "www.${config.deployment-dd-ix.domain}";

        locations = {
          "/".return = "301 https://${config.deployment-dd-ix.domain}$request_uri";
        };
      };
      "${config.deployment-dd-ix.domain}" = {
        listen = [{
          addr = "[::]:443";
          proxyProtocol = true;
          ssl = true;
        }];

        onlySSL = true;
        useACMEHost = config.deployment-dd-ix.domain;

        locations = {
          "/robots.txt".return = "200 \"User-agent: *\nAllow: /\"";
          "/g/ml".return = "301 https://${config.deployment-dd-ix.domain}/news/subscribe";
        };
      };
      "content.${config.deployment-dd-ix.domain}" = {
        listen = [{
          addr = "[::]:443";
          proxyProtocol = true;
          ssl = true;
        }];

        onlySSL = true;
        useACMEHost = "content.${config.deployment-dd-ix.domain}";
        locations = {
          "/robots.txt".return = "200 \"User-agent: *\nAllow: /\"";
        };
      };
      "talks.${config.deployment-dd-ix.domain}" = {
        listen = [{
          addr = "[::]:443";
          proxyProtocol = true;
          ssl = true;
        }];

        onlySSL = true;
        useACMEHost = "talks.${config.deployment-dd-ix.domain}";

        root = pkgs.fetchFromGitea {
          domain = "codeberg.org";
          owner = "dd-ix";
          repo = "ddix-talks";
          fetchSubmodules = true;
          rev = "2cf23142099b4fad36547111585abeb1257e72b0";
          hash = "sha256-E3e/OFoU4xnyRV+5na+PRzZwQ0AxI1WAi82qkAV+g5A=";
        };

        locations = {
          "/robots.txt".return = "200 \"User-agent: *\\nAllow: /\"";
        };
      };
    };
  };

  dd-ix = {
    website = {
      enable = true;
      domain = "${config.deployment-dd-ix.domain}";
    };
    website-content-api = {
      enable = true;
      domain = "content.${config.deployment-dd-ix.domain}";
      http = {
        host = "127.0.0.1";
        port = 9123;
      };
      listmonk = {
        host = "https://lists.dd-ix.net";
        port = 443;
        user = "admin";
        passwordFile = config.sops.secrets.web_listmonk_admin_pw.path;
        allowed_lists = [ 3 ];
      };
      url = "https://content.${config.deployment-dd-ix.domain}/";
      prometheusUrl = "https://svc-prom01.${config.deployment-dd-ix.domain}/";
      ixpManagerUrl = "https://portal.${config.deployment-dd-ix.domain}/";
    };
  };
}
