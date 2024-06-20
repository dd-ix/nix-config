{ self, config, lib, ... }:

let
  base = {
    image = "openproject/openproject:14-slim";
    extraOptions = [ "--network=host" ];

    environmentFiles = [ config.sops.secrets."openproject_env".path ];

    environment = {
      IMAP_ENABLED = "false";
      OPENPROJECT_CACHE__MEMCACHE__SERVER = "127.0.0.1:11211";
      OPENPROJECT_HOST__NAME = "orga.dd-ix.net";
      OPENPROJECT_HSTS = "true";
      OPENPROJECT_HTTPS = "true";
      OPENPROJECT_RAILS__RELATIVE__URL__ROOT = "";
      RAILS_CACHE_STORE = "memcache";
      RAILS_MAX_THREADS = "16";
      RAILS_MIN_THREADS = "4";
    };
  };
in
{
  sops.secrets."openproject_env" = {
    sopsFile = self + "/secrets/management/orga.yaml";
    owner = "root";
  };

  services.memcached.enable = true;

  systemd.services."podman-ddix-orga-seeder".serviceConfig.Restart = lib.mkForce "on-failure";

  services.nginx = {
    enable = true;

    virtualHosts."orga.${config.dd-ix.domain}" = {
      listen = [{
        addr = "[::]:443";
        proxyProtocol = true;
        ssl = true;
      }];

      onlySSL = true;
      useACMEHost = "orga.${config.dd-ix.domain}";

      locations."/" = {
        root = "/var/lib/openproject/public";
        # just something that does not exists
        index = "X6XewZMsmreGIxx1lCdp0Yo1X4qHTivW";
        tryFiles = "$uri @website";
        extraConfig = ''
          expires max;
          access_log off;
        '';
      };

      locations."@website".proxyPass = "http://127.0.0.1:8080";
    };
  };

  virtualisation.oci-containers.containers."ddix-orga-cron" = base // {
    volumes = [
      "/var/lib/openproject/assets:/var/openproject/assets:rw"
    ];
    cmd = [ "./docker/prod/cron" ];
    dependsOn = [ "ddix-orga-seeder" ];
  };

  virtualisation.oci-containers.containers."ddix-orga-seeder" = base // {
    volumes = [
      "/var/lib/openproject/assets:/var/openproject/assets:rw"
    ];
    cmd = [ "./docker/prod/seeder" ];
  };

  virtualisation.oci-containers.containers."ddix-orga-web" = base // {
    volumes = [
      "/var/lib/openproject/public:/app/public:rw"
      "/var/lib/openproject/assets:/var/openproject/assets:rw"
    ];
    cmd = [ "./docker/prod/web" ];
    dependsOn = [ "ddix-orga-seeder" ];
  };

  virtualisation.oci-containers.containers."ddix-orga-worker" = base // {
    volumes = [
      "/var/lib/openproject/assets:/var/openproject/assets:rw"
    ];
    cmd = [ "./docker/prod/worker" ];
    dependsOn = [ "ddix-orga-seeder" ];
  };
}
