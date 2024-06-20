{ self, config, lib, ... }:

let
  env = {
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
in
{
  sops.secrets."openproject_env" = {
    sopsFile = self + "/secrets/management/orga.yaml";
    owner = "root";
  };

  services.nginx.enable = true;
  services.memcached.enable = true;

  systemd.services."podman-ddix-orga-seeder".serviceConfig.Restart = lib.mkForce "on-failure";

  services.nginx.virtualHosts."orga.${config.dd-ix.domain}" = {
    listen = [{
      addr = "[::]:443";
      proxyProtocol = true;
      ssl = true;
    }];

    onlySSL = true;
    useACMEHost = "orga.${config.dd-ix.domain}";

    locations."/".proxyPass = "http://127.0.0.1:8080";
  };

  virtualisation.oci-containers.containers."ddix-orga-cron" = {
    image = "openproject/openproject:14-slim";
    environment = env;
    environmentFiles = [ config.sops.secrets."openproject_env".path ];
    volumes = [
      "/var/lib/openproject/assets:/var/openproject/assets:rw"
    ];
    cmd = [ "./docker/prod/cron" ];
    extraOptions = [ "--network=host" ];
    dependsOn = [ "ddix-orga-seeder" ];
  };

  virtualisation.oci-containers.containers."ddix-orga-seeder" = {
    image = "openproject/openproject:14-slim";
    environment = env;
    environmentFiles = [ config.sops.secrets."openproject_env".path ];
    volumes = [
      "/var/lib/openproject/assets:/var/openproject/assets:rw"
    ];
    cmd = [ "./docker/prod/seeder" ];
    extraOptions = [ "--network=host" ];
  };

  virtualisation.oci-containers.containers."ddix-orga-web" = {
    image = "openproject/openproject:14-slim";
    environment = env;
    environmentFiles = [ config.sops.secrets."openproject_env".path ];
    volumes = [
      "/var/lib/openproject/public:/app/public:rw"
      "/var/lib/openproject/assets:/var/openproject/assets:rw"
    ];
    cmd = [ "./docker/prod/web" ];
    extraOptions = [
      "--health-cmd='[\"curl\",\"-f\",\"http://localhost:8080/health_checks/default\"]'"
      "--health-interval=10s"
      "--health-retries=3"
      "--health-start-period=30s"
      "--health-timeout=3s"
      "--network=host"
    ];
    dependsOn = [ "ddix-orga-seeder" ];
  };

  virtualisation.oci-containers.containers."ddix-orga-worker" = {
    image = "openproject/openproject:14-slim";
    environment = env;
    environmentFiles = [ config.sops.secrets."openproject_env".path ];
    volumes = [
      "/var/lib/openproject/assets:/var/openproject/assets:rw"
    ];
    cmd = [ "./docker/prod/worker" ];
    extraOptions = [ "--network=host" ];
    dependsOn = [ "ddix-orga-seeder" ];
  };
}
