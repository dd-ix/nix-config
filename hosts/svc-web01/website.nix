{ config, pkgs, ... }:

{
  services.nginx = {
    enable = true;
    virtualHosts = {
      "www.${config.dd-ix.domain}" = {
        listen = [
          {
            addr = "[::]";
            port = 443;
            proxyProtocol = true;
            ssl = true;
          }
          {
            addr = "[::1]";
            port = 443;
            ssl = true;
          }
          {
            addr = "127.0.0.1";
            port = 443;
            ssl = true;
          }
        ];

        onlySSL = true;
        useACMEHost = "www.${config.dd-ix.domain}";

        locations = {
          "/".return = "301 https://${config.dd-ix.domain}$request_uri";
        };
      };
      "${config.dd-ix.domain}" = {
        listen = [
          {
            addr = "[::]";
            port = 443;
            proxyProtocol = true;
            ssl = true;
          }
          {
            addr = "[::1]";
            port = 443;
            ssl = true;
          }
          {
            addr = "127.0.0.1";
            port = 443;
            ssl = true;
          }
        ];

        onlySSL = true;
        useACMEHost = config.dd-ix.domain;

        locations = {
          "= /robots.txt".return = "200 \"User-agent: *\\nAllow: /\"";
          "= /g/news".return = "301 https://lists.dd-ix.net/postorius/lists/news.lists.dd-ix.net/";
          "= /g/ddnog".return = "301 https://lists.dd-ix.net/postorius/lists/ddnog.lists.dd-ix.net/";
          "= /g/opening".return = "301 https://dd-ix.net/event/opening";
          "= /g/vint".return = "301 https://videocampus.sachsen.de/video/opening-message-from-vint-cerf-dd-ix-opening-november-25-2024/698/815b60bd0c94e0274ad28fc8c177ff64";

          # legacy
          "= /g/ml".return = "301 https://lists.dd-ix.net/postorius/lists/news.lists.dd-ix.net/";
          "= /news/subscribe".return = "301 https://lists.dd-ix.net/postorius/lists/news.lists.dd-ix.net/";
          "= /de/news/subscribe".return = "301 https://lists.dd-ix.net/postorius/lists/news.lists.dd-ix.net/";
          "= /en/news/subscribe".return = "301 https://lists.dd-ix.net/postorius/lists/news.lists.dd-ix.net/";
          "= /blog/subscribe".return = "301 https://lists.dd-ix.net/postorius/lists/news.lists.dd-ix.net/";
          "= /de/blog/subscribe".return = "301 https://lists.dd-ix.net/postorius/lists/news.lists.dd-ix.net/";
          "= /en/blog/subscribe".return = "301 https://lists.dd-ix.net/postorius/lists/news.lists.dd-ix.net/";
        };
      };
      "content.${config.dd-ix.domain}" = {
        listen = [
          {
            addr = "[::]";
            port = 443;
            proxyProtocol = true;
            ssl = true;
          }
          {
            addr = "[::1]";
            port = 443;
            ssl = true;
          }
          {
            addr = "127.0.0.1";
            port = 443;
            ssl = true;
          }
        ];

        onlySSL = true;
        useACMEHost = "content.${config.dd-ix.domain}";
        locations = {
          "= /robots.txt".return = "200 \"User-agent: *\\nAllow: /\"";
        };
      };
      "talks.${config.dd-ix.domain}" = {
        listen = [
          {
            addr = "[::]";
            port = 443;
            proxyProtocol = true;
            ssl = true;
          }
          {
            addr = "[::1]";
            port = 443;
            ssl = true;
          }
          {
            addr = "127.0.0.1";
            port = 443;
            ssl = true;
          }
        ];

        onlySSL = true;
        useACMEHost = "talks.${config.dd-ix.domain}";

        root = pkgs.fetchFromGitea {
          domain = "codeberg.org";
          owner = "dd-ix";
          repo = "ddix-talks";
          fetchSubmodules = true;
          rev = "1b55aca651543da88866dd2205264a733b8638c4";
          hash = "sha256-EhSYgdG48SQuFq+kMWYmVaQkUc3Cl1yOJ4dDFjalehU=";
        };

        locations = {
          "= /robots.txt".return = "200 \"User-agent: *\\nAllow: /\"";
        };
      };
      "opening.${config.dd-ix.domain}" = {
        listen = [
          {
            addr = "[::]";
            port = 443;
            proxyProtocol = true;
            ssl = true;
          }
          {
            addr = "[::1]";
            port = 443;
            ssl = true;
          }
          {
            addr = "127.0.0.1";
            port = 443;
            ssl = true;
          }
        ];

        onlySSL = true;
        useACMEHost = "opening.${config.dd-ix.domain}";

        # im Kontakt mit Heise genutzt, @Matthias
        locations."/".return = "301 https://dd-ix.net/event/opening";
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
