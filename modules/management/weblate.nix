{ self, lib, config, pkgs, ... }:

{
  sops.secrets."weblate/django_secret_key" = {
    sopsFile = self + /secrets/management/translate.yaml;
    owner = config.systemd.services.weblate.serviceConfig.User;
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
        user = "noreply@translate.dd-ix.net";
      };
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
