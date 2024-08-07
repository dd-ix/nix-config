{ self, config, pkgs, ... }: {

  sops.secrets.web_listmonk_admin_pw = {
    sopsFile = self + "/secrets/management/web.yaml";
    owner = "root";
  };

  services.nginx = {
    enable = true;
    virtualHosts = {
      "www.${config.dd-ix.domain}" = {
        listen = [{
          addr = "[::]:443";
          proxyProtocol = true;
          ssl = true;
        }];

        onlySSL = true;
        useACMEHost = "www.${config.dd-ix.domain}";

        locations = {
          "/".return = "301 https://${config.dd-ix.domain}$request_uri";
        };
      };
      "${config.dd-ix.domain}" = {
        listen = [{
          addr = "[::]:443";
          proxyProtocol = true;
          ssl = true;
        }];

        onlySSL = true;
        useACMEHost = config.dd-ix.domain;

        locations = {
          "/robots.txt".return = "200 \"User-agent: *\\nAllow: /\"";
          "/g/ml".return = "301 https://${config.dd-ix.domain}/news/subscribe";
          "/g/ddnog".return = "301 https://lists.dd-ix.net/postorius/lists/ddnog.lists.dd-ix.net/";
        };
      };
      "content.${config.dd-ix.domain}" = {
        listen = [{
          addr = "[::]:443";
          proxyProtocol = true;
          ssl = true;
        }];

        onlySSL = true;
        useACMEHost = "content.${config.dd-ix.domain}";
        locations = {
          "/robots.txt".return = "200 \"User-agent: *\\nAllow: /\"";
        };
      };
      "talks.${config.dd-ix.domain}" = {
        listen = [{
          addr = "[::]:443";
          proxyProtocol = true;
          ssl = true;
        }];

        onlySSL = true;
        useACMEHost = "talks.${config.dd-ix.domain}";

        root = pkgs.fetchFromGitea {
          domain = "codeberg.org";
          owner = "dd-ix";
          repo = "ddix-talks";
          fetchSubmodules = true;
          rev = "eeb138084cf314ce13e126da5625e46849047b2b";
          hash = "sha256-jk+z6A+vGUh0wu5lF3oUOHKtZ1UsjejQNcPAcj43SGw=";
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
      domain = config.dd-ix.domain;
      contentApi = "https://content.${config.dd-ix.domain}";
    };
    website-content-api = {
      enable = true;
      domain = "content.${config.dd-ix.domain}";
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
      url = "https://content.${config.dd-ix.domain}/";
      prometheusUrl = "https://svc-prom02.${config.dd-ix.domain}/";
      ixpManagerUrl = "https://portal.${config.dd-ix.domain}/";
    };
  };
}
