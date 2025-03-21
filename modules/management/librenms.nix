{ self, config, ... }:

{
  sops.secrets."nms_db_pass" = {
    sopsFile = self + /secrets/management/nms.yaml;
    owner = config.services.librenms.user;
  };

  services.librenms = {
    enable = true;
    database = {
      host = "svc-mari01.dd-ix.net";
      port = 3306;
      username = "librenms";
      passwordFile = config.sops.secrets."nms_db_pass".path;
      database = "librenms";
    };
    settings = { };
    environmentFile = "";
    nginx = {
      listen = [{
        addr = "[::]:443";
        proxyProtocol = true;
        ssl = true;
      }];

      onlySSL = true;
      useACMEHost = "nms.${config.dd-ix.domain}";
    };
  };
}
