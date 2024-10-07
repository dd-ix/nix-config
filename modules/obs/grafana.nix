{ self, config, ... }:
{
  sops.secrets."obs_db_pw" = {
    sopsFile = self + "/secrets/management/obs.yaml";
    owner = config.systemd.services.grafana.serviceConfig.User;
  };
  sops.secrets."obs_auth_secret_key" = {
    sopsFile = self + "/secrets/management/obs.yaml";
    owner = config.systemd.services.grafana.serviceConfig.User;
  };

  services.nginx = {
    enable = true;
    virtualHosts."obs.${config.dd-ix.domain}" = {
      listen = [{
        addr = "[::]:443";
        proxyProtocol = true;
        ssl = true;
      }];

      onlySSL = true;
      useACMEHost = "obs.${config.dd-ix.domain}";

      locations."/" = {
        proxyPass = "http://${toString config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
        proxyWebsockets = true;
      };
    };
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        enforce_domain = true;
        domain = "obs.${config.dd-ix.domain}";
        root_url = "https://obs.${config.dd-ix.domain}";
        enable_gzip = true;
      };
      log.level = "warn";
      security = {
        disable_initial_admin_creation = true;
        disable_gravatar = true;
        data_source_proxy_whitelist = [
          "svc-prom01.dd-ix.net:443"
          "svc-prom02.dd-ix.net:443"
        ];
        csrf_trusted_origins = [
          "auth.dd-ix.net"
        ];
        cookie_secure = true;
        cookie_samesite = "strict";
        content_security_policy = true;
        strict_transport_security = true;
        allow_embedding = false;
      };
      smtp = {
        enabled = true;
        host = "svc-mta01.dd-ix.net:25";
        from_name = "DD-IX OBS";
        from_address = "noreply@obs.dd-ix.net";
        startTLS_policy = "MandatoryStartTLS";
      };
      database = {
        user = "grafana";
        type = "postgres";
        ssl_mode = "verify-full";
        server_cert_name = "svc-pg01.dd-ix.net";
        name = "grafana";
        host = "svc-pg01.dd-ix.net";
        password = "$__file{${config.sops.secrets."obs_db_pw".path}}";
      };
      analytics = {
        reporting_enabled = false;
        feedback_links_enabled = false;
      };
      auth = {
        signout_redirect_url = "https://auth.dd-ix.net/application/o/obs/end-session/";
      };
      "auth.generic_oauth" = {
        name = "DD-IX Auth";
        enabled = true;
        client_id = "0JoW22eMuKF2CPfQUjL1AlnuQ96Bx6fGdJt9iZJa";
        client_secret = "$__file{${config.sops.secrets."obs_auth_secret_key".path}}";
        scopes = "openid email profile";
        auto_login = true;
        disable_login_form = true;
        auth_url = "https://auth.dd-ix.net/application/o/authorize/";
        token_url = "https://auth.dd-ix.net/application/o/token/";
        api_url = "https://auth.dd-ix.net/application/o/userinfo/";
        role_attribute_path = "contains(groups, 'DDIX-Board') && 'Admin' || contains(groups, 'DDIX-Tech') && 'Editor' || 'Viewer'";
        login_attribute_path = "preferred_username";
      };
      user.auto_assign_org = true;
      remote_cache = {
        type = "redis";
        connstr = "addr=${config.services.redis.servers.grafana.bind}:${builtins.toString config.services.redis.servers.grafana.port},pool_size=100,db=0,ssl=false";
      };
    };
    provision = {
      enable = true;
      datasources.settings = {
        deleteDatasources = [
          { name = "svc-prom01"; orgId = 1; }
          { name = "svc-prom01_15s"; orgId = 1; }
          { name = "svc-prom01_1m"; orgId = 1; }
          { name = "svc-prom02_15s"; orgId = 1; }
          { name = "svc-prom02_1m"; orgId = 1; }
        ];
        datasources = [
          {
            name = "svc-prom02_15s";
            url = "https://svc-prom02.dd-ix.net:443";
            uid = "svc-prom02_15s";
            type = "prometheus";
            access = "proxy";
            enable = true;
            jsonData.timeInterval = "15s";
          }
          {
            name = "svc-prom02_1m";
            url = "https://svc-prom02.dd-ix.net:443";
            uid = "svc-prom02_1m";
            type = "prometheus";
            access = "proxy";
            enable = true;
            jsonData.timeInterval = "1m";
          }
          {
            name = "svc-prom01_1m";
            url = "https://svc-prom01.dd-ix.net:443";
            uid = "svc-prom01_1m";
            type = "prometheus";
            access = "proxy";
            enable = true;
            jsonData.timeInterval = "1m";
          }
        ];
      };
    };
  };

  services.redis.servers.grafana = {
    enable = true;
    port = 6379;
  };
}
