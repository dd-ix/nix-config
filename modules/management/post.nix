{ self, config, ... }:

{
  sops.secrets."post_api_token" = {
    sopsFile = self + "/secrets/management/mta.yaml";
  };

  services = {
    post = {
      enable = true;
      smtp = {
        addr = "::1";
        port = 25;
      };
      templateGlob = self + "/resources/email_templates/*.html";
      apiTokenFile = config.sops.secrets."post_api_token".path;
    };

    nginx = {
      enable = true;
      virtualHosts."svc-mta01.${config.dd-ix.domain}" = {
        listen = [{
          addr = "[::]:443";
          ssl = true;
        }];

        onlySSL = true;
        useACMEHost = "svc-mta01.${config.dd-ix.domain}";

        extraConfig = ''
          allow 2a01:7700:80b0::/48;
          deny all;
        '';

        locations =
          let
            cfg = config.systemd.services.post.environment;
          in
          {
            "/".proxyPass = "http://${cfg.POST_LISTEN_ADDR}";
          };
      };
    };
  };
}
