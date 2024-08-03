{ self, config, ... }:

{
  sops.secrets."post_api_token" = {
    sopsFile = self + "/secrets/management/mta.yaml";
  };

  services.post = {
    enable = true;
    smtp = {
      addr = "::1";
      port = 25;
    };
    templateGlob = self + "/resources/email_templates/*.html";
    apiTokenFile = config.sops.secrets."post_api_token".path;
  };
}
