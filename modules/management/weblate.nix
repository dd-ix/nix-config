{ lib, config, ... }:

{
  services.weblate = {
    enable = true;
    localDomain = "weblate.${config.dd-ix.domain}";
    smtp = {
      enable = true;
      host = "svc-mta01.dd-ix.net";
      user = "noreply@translate.dd-ix.net";
    };
  };

  # don't use the local database, we have svc-pg01.dd-ix.net
  services.postgresql.enable = lib.mkForce false;
}
