{self, lib, config, ... }:

{
  sops.secrets."weblate/django_secret_key" = {
    sopsFile = self + /secrets/management/translate.yaml;
    owner = config.systemd.services.weblate.serviceConfig.User;
  };

  services.weblate = {
    enable = true;
    localDomain = "weblate.${config.dd-ix.domain}";
    djangoSecretKeyFile = config.sops.secrets."weblate/django_secret_key".path;
    smtp = {
      enable = true;
      host = "svc-mta01.dd-ix.net";
      user = "noreply@translate.dd-ix.net";
    };
  };

  # don't use the local database, we have svc-pg01.dd-ix.net
  services.postgresql.enable = lib.mkForce false;
}
