# Auto-generated using compose2nix v0.2.0-pre.
{ self, pkgs, lib, config, ... }:

{
  sops.secrets."openproject_env" = {
    sopsFile = self + "/secrets/management/openproject.yaml";
    owner = "root";
  };

  # Runtime
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
    defaultNetwork.settings = {
      # Required for container networking to be able to use names.
      dns_enabled = true;
    };
  };
  virtualisation.oci-containers.backend = "podman";

  # Containers
  virtualisation.oci-containers.containers."ddix-orga-autoheal" = {
    image = "willfarrell/autoheal:1.2.0";
    environment = {
      AUTOHEAL_CONTAINER_LABEL = "autoheal";
      AUTOHEAL_INTERVAL = "30";
      AUTOHEAL_START_PERIOD = "600";
    };
    volumes = [
      "/var/run/docker.sock:/var/run/docker.sock:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=autoheal"
      "--network=ddix-orga_default"
    ];
  };
  systemd.services."podman-ddix-orga-autoheal" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "\"no\"";
    };
    after = [
      "podman-network-ddix-orga_default.service"
    ];
    requires = [
      "podman-network-ddix-orga_default.service"
    ];
    partOf = [
      "podman-compose-ddix-orga-root.target"
    ];
    wantedBy = [
      "podman-compose-ddix-orga-root.target"
    ];
  };
  virtualisation.oci-containers.containers."ddix-orga-cache" = {
    image = "memcached";
    log-driver = "journald";
    extraOptions = [
      "--network-alias=cache"
      "--network=ddix-orga_backend"
    ];
  };
  systemd.services."podman-ddix-orga-cache" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-ddix-orga_backend.service"
    ];
    requires = [
      "podman-network-ddix-orga_backend.service"
    ];
    partOf = [
      "podman-compose-ddix-orga-root.target"
    ];
    wantedBy = [
      "podman-compose-ddix-orga-root.target"
    ];
  };
  virtualisation.oci-containers.containers."ddix-orga-cron" = {
    image = "openproject/openproject:14-slim";
    environment = {
      IMAP_ENABLED = "false";
      OPENPROJECT_CACHE__MEMCACHE__SERVER = "cache:11211";
      OPENPROJECT_HOST__NAME = "localhost:8080";
      OPENPROJECT_HSTS = "true";
      OPENPROJECT_HTTPS = "true";
      OPENPROJECT_RAILS__RELATIVE__URL__ROOT = "";
      RAILS_CACHE_STORE = "memcache";
      RAILS_MAX_THREADS = "16";
      RAILS_MIN_THREADS = "4";
    };
    environmentFiles = [ config.sops.secrets."openproject_env".path ];
    volumes = [
      "opdata:/var/openproject/assets:rw"
    ];
    cmd = [ "./docker/prod/cron" ];
    dependsOn = [
      "ddix-orga-cache"
      "ddix-orga-db"
      "ddix-orga-seeder"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=cron"
      "--network=ddix-orga_backend"
    ];
  };
  systemd.services."podman-ddix-orga-cron" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-ddix-orga_backend.service"
      "podman-volume-ddix-orga_opdata.service"
    ];
    requires = [
      "podman-network-ddix-orga_backend.service"
      "podman-volume-ddix-orga_opdata.service"
    ];
    partOf = [
      "podman-compose-ddix-orga-root.target"
    ];
    wantedBy = [
      "podman-compose-ddix-orga-root.target"
    ];
  };
  virtualisation.oci-containers.containers."ddix-orga-db" = {
    image = "postgres:13";
    environment = {
      POSTGRES_DB = "openproject";
      POSTGRES_PASSWORD = "p4ssw0rd";
    };
    volumes = [
      "pgdata:/var/lib/postgresql/data:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=db"
      "--network=ddix-orga_backend"
    ];
  };
  systemd.services."podman-ddix-orga-db" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-ddix-orga_backend.service"
      "podman-volume-ddix-orga_pgdata.service"
    ];
    requires = [
      "podman-network-ddix-orga_backend.service"
      "podman-volume-ddix-orga_pgdata.service"
    ];
    partOf = [
      "podman-compose-ddix-orga-root.target"
    ];
    wantedBy = [
      "podman-compose-ddix-orga-root.target"
    ];
  };
  virtualisation.oci-containers.containers."ddix-orga-proxy" = {
    image = "caddy:2";
    environment = {
      APP_HOST = "web";
    };
    volumes = [
      "/tmp/openproject/compose/Caddyfile.template:/etc/caddy/Caddyfile.template:ro"
      "/tmp/openproject/compose/proxy-entrypoint.sh:/usr/local/bin/proxy-entrypoint.sh:ro"
      "assets:/public:ro"
    ];
    ports = [
      "8080:80/tcp"
    ];
    cmd = [ "/usr/local/bin/proxy-entrypoint.sh" ];
    dependsOn = [
      "ddix-orga-web"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=proxy"
      "--network=ddix-orga_frontend"
    ];
  };
  systemd.services."podman-ddix-orga-proxy" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-ddix-orga_frontend.service"
      "podman-volume-ddix-orga_assets.service"
    ];
    requires = [
      "podman-network-ddix-orga_frontend.service"
      "podman-volume-ddix-orga_assets.service"
    ];
    partOf = [
      "podman-compose-ddix-orga-root.target"
    ];
    wantedBy = [
      "podman-compose-ddix-orga-root.target"
    ];
  };
  virtualisation.oci-containers.containers."ddix-orga-seeder" = {
    image = "openproject/openproject:14-slim";
    environment = {
      IMAP_ENABLED = "false";
      OPENPROJECT_CACHE__MEMCACHE__SERVER = "cache:11211";
      OPENPROJECT_HOST__NAME = "localhost:8080";
      OPENPROJECT_HSTS = "true";
      OPENPROJECT_HTTPS = "true";
      OPENPROJECT_RAILS__RELATIVE__URL__ROOT = "";
      RAILS_CACHE_STORE = "memcache";
      RAILS_MAX_THREADS = "16";
      RAILS_MIN_THREADS = "4";
    };
    environmentFiles = [ config.sops.secrets."openproject_env".path ];
    volumes = [
      "opdata:/var/openproject/assets:rw"
    ];
    cmd = [ "./docker/prod/seeder" ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=seeder"
      "--network=ddix-orga_backend"
    ];
  };
  systemd.services."podman-ddix-orga-seeder" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "on-failure";
    };
    after = [
      "podman-network-ddix-orga_backend.service"
      "podman-volume-ddix-orga_opdata.service"
    ];
    requires = [
      "podman-network-ddix-orga_backend.service"
      "podman-volume-ddix-orga_opdata.service"
    ];
    partOf = [
      "podman-compose-ddix-orga-root.target"
    ];
    wantedBy = [
      "podman-compose-ddix-orga-root.target"
    ];
  };
  virtualisation.oci-containers.containers."ddix-orga-web" = {
    image = "openproject/openproject:14-slim";
    environment = {
      IMAP_ENABLED = "false";
      OPENPROJECT_CACHE__MEMCACHE__SERVER = "cache:11211";
      OPENPROJECT_HOST__NAME = "localhost:8080";
      OPENPROJECT_HSTS = "true";
      OPENPROJECT_HTTPS = "true";
      OPENPROJECT_RAILS__RELATIVE__URL__ROOT = "";
      RAILS_CACHE_STORE = "memcache";
      RAILS_MAX_THREADS = "16";
      RAILS_MIN_THREADS = "4";
    };
    environmentFiles = [ config.sops.secrets."openproject_env".path ];
    volumes = [
      "assets:/app/public:rw"
      "opdata:/var/openproject/assets:rw"
    ];
    cmd = [ "./docker/prod/web" ];
    labels = {
      "autoheal" = "true";
    };
    dependsOn = [
      "ddix-orga-cache"
      "ddix-orga-db"
      "ddix-orga-seeder"
    ];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd='[\"curl\",\"-f\",\"http://localhost:8080/health_checks/default\"]'"
      "--health-interval=10s"
      "--health-retries=3"
      "--health-start-period=30s"
      "--health-timeout=3s"
      "--network-alias=web"
      "--network=ddix-orga_backend"
      "--network=ddix-orga_frontend"
    ];
  };
  systemd.services."podman-ddix-orga-web" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-ddix-orga_backend.service"
      "podman-network-ddix-orga_frontend.service"
      "podman-volume-ddix-orga_assets.service"
      "podman-volume-ddix-orga_opdata.service"
    ];
    requires = [
      "podman-network-ddix-orga_backend.service"
      "podman-network-ddix-orga_frontend.service"
      "podman-volume-ddix-orga_assets.service"
      "podman-volume-ddix-orga_opdata.service"
    ];
    partOf = [
      "podman-compose-ddix-orga-root.target"
    ];
    wantedBy = [
      "podman-compose-ddix-orga-root.target"
    ];
  };
  virtualisation.oci-containers.containers."ddix-orga-worker" = {
    image = "openproject/openproject:14-slim";
    environment = {
      IMAP_ENABLED = "false";
      OPENPROJECT_CACHE__MEMCACHE__SERVER = "cache:11211";
      OPENPROJECT_HOST__NAME = "localhost:8080";
      OPENPROJECT_HSTS = "true";
      OPENPROJECT_HTTPS = "true";
      OPENPROJECT_RAILS__RELATIVE__URL__ROOT = "";
      RAILS_CACHE_STORE = "memcache";
      RAILS_MAX_THREADS = "16";
      RAILS_MIN_THREADS = "4";
    };
    environmentFiles = [ config.sops.secrets."openproject_env".path ];
    volumes = [
      "opdata:/var/openproject/assets:rw"
    ];
    cmd = [ "./docker/prod/worker" ];
    dependsOn = [
      "ddix-orga-cache"
      "ddix-orga-db"
      "ddix-orga-seeder"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=worker"
      "--network=ddix-orga_backend"
    ];
  };
  systemd.services."podman-ddix-orga-worker" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-ddix-orga_backend.service"
      "podman-volume-ddix-orga_opdata.service"
    ];
    requires = [
      "podman-network-ddix-orga_backend.service"
      "podman-volume-ddix-orga_opdata.service"
    ];
    partOf = [
      "podman-compose-ddix-orga-root.target"
    ];
    wantedBy = [
      "podman-compose-ddix-orga-root.target"
    ];
  };

  # Networks
  systemd.services."podman-network-ddix-orga_backend" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "${pkgs.podman}/bin/podman network rm -f ddix-orga_backend";
    };
    script = ''
      podman network inspect ddix-orga_backend || podman network create ddix-orga_backend
    '';
    partOf = [ "podman-compose-ddix-orga-root.target" ];
    wantedBy = [ "podman-compose-ddix-orga-root.target" ];
  };
  systemd.services."podman-network-ddix-orga_default" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "${pkgs.podman}/bin/podman network rm -f ddix-orga_default";
    };
    script = ''
      podman network inspect ddix-orga_default || podman network create ddix-orga_default
    '';
    partOf = [ "podman-compose-ddix-orga-root.target" ];
    wantedBy = [ "podman-compose-ddix-orga-root.target" ];
  };
  systemd.services."podman-network-ddix-orga_frontend" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "${pkgs.podman}/bin/podman network rm -f ddix-orga_frontend";
    };
    script = ''
      podman network inspect ddix-orga_frontend || podman network create ddix-orga_frontend
    '';
    partOf = [ "podman-compose-ddix-orga-root.target" ];
    wantedBy = [ "podman-compose-ddix-orga-root.target" ];
  };

  # Volumes
  systemd.services."podman-volume-ddix-orga_assets" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect ddix-orga_assets || podman volume create ddix-orga_assets
    '';
    partOf = [ "podman-compose-ddix-orga-root.target" ];
    wantedBy = [ "podman-compose-ddix-orga-root.target" ];
  };
  systemd.services."podman-volume-ddix-orga_opdata" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect ddix-orga_opdata || podman volume create ddix-orga_opdata
    '';
    partOf = [ "podman-compose-ddix-orga-root.target" ];
    wantedBy = [ "podman-compose-ddix-orga-root.target" ];
  };
  systemd.services."podman-volume-ddix-orga_pgdata" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect ddix-orga_pgdata || podman volume create ddix-orga_pgdata
    '';
    partOf = [ "podman-compose-ddix-orga-root.target" ];
    wantedBy = [ "podman-compose-ddix-orga-root.target" ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-ddix-orga-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
