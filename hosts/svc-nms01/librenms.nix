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
        addr = "[::]";
        port = 443;
        proxyProtocol = true;
        ssl = true;
      }];

      onlySSL = true;
      useACMEHost = "nms.${config.dd-ix.domain}";
    };
    phpOptions = {
      # https://docs.librenms.org/Support/Performance/#for-web-servers-using-mod_php-and-php-fpm
      "opcache.enable" = 1;
      "opcache.memory_consumption" = 256;
    };
    # https://docs.librenms.org/Support/Performance/#optimise-poller-wrapper
    pollerThreads = config.microvm.vcpu * 2;
  };
}
