{ self, config, pkgs, ... }:

{
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
          "/g/news".return = "301 https://lists.dd-ix.net/postorius/lists/news.lists.dd-ix.net/";
          "/g/ddnog".return = "301 https://lists.dd-ix.net/postorius/lists/ddnog.lists.dd-ix.net/";

          # legacy
          "/g/ml".return = "301 https://lists.dd-ix.net/postorius/lists/news.lists.dd-ix.net/";
          "/news/subscribe".return = "301 https://lists.dd-ix.net/postorius/lists/news.lists.dd-ix.net/";
          "/de/news/subscribe".return = "301 https://lists.dd-ix.net/postorius/lists/news.lists.dd-ix.net/";
          "/en/news/subscribe".return = "301 https://lists.dd-ix.net/postorius/lists/news.lists.dd-ix.net/";
          "/blog/subscribe".return = "301 https://lists.dd-ix.net/postorius/lists/news.lists.dd-ix.net/";
          "/de/blog/subscribe".return = "301 https://lists.dd-ix.net/postorius/lists/news.lists.dd-ix.net/";
          "/en/blog/subscribe".return = "301 https://lists.dd-ix.net/postorius/lists/news.lists.dd-ix.net/";
          "/event".return = "301 https://dd-ix.net/blog";
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
          "= /robots.txt".return = "200 \"User-agent: *\\nAllow: /\"";
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
          "= /robots.txt".return = "200 \"User-agent: *\\nAllow: /\"";
        };
      };
      "opening.${config.dd-ix.domain}" = {
        listen = [{
          addr = "[::]:443";
          proxyProtocol = true;
          ssl = true;
        }];

        onlySSL = true;
        useACMEHost = "opening.${config.dd-ix.domain}";

        locations = {
          "= /" = {
            alias = self + /resources/static;
            tryFiles = "/opening.html =404";
          };
          "= /robots.txt".return = "200 \"User-agent: *\\nAllow: /\"";
        };
      };
    };
  };

  dd-ix = {
    website = {
      enable = true;
      inherit (config.dd-ix) domain;
      contentApi = "https://content.${config.dd-ix.domain}";
    };
    website-content-api = {
      enable = true;
      domain = "content.${config.dd-ix.domain}";
      http = {
        host = "127.0.0.1";
        port = 9123;
      };
      url = "https://content.${config.dd-ix.domain}/";
      prometheusUrl = "https://svc-prom02.${config.dd-ix.domain}/";
      ixpManagerUrl = "https://portal.${config.dd-ix.domain}/";
    };
  };
}
