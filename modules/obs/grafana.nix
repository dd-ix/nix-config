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

  services.grafana = {
    enable = true;
    settings = {
      server = {
        protocol = true;
        enforce_domain = true;
        domain = "obs.dd-ix.net";
      };
      security = {
        disable_initial_admin_creation = true;
        disable_gravatar = true;
        data_source_proxy_whitelist = [
          "svc-prom01.dd-ix.net:443"
        ];
        csrf_trusted_origins = [
          "auth.dd-ix.net"
        ];
        cookie_secure = true;
        cookie_samesite = "strict";
        content_security_policy = true;
        # allow_embedding = true;
      };
      smtp = {
        enable = true;
        host = "mta.dd-ix.net";
        from_name = "DD-IX OBS";
        from_address = "noreply@obs.dd-ix.net";
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
        signout_redirect_url = "https://authentik.company/application/o/obs/end-session/";
        oauth_auto_login = true;
      };
      "auth.generic_oauth" = {
        name = "authentik";
        enabled = true;
        client_id = "0JoW22eMuKF2CPfQUjL1AlnuQ96Bx6fGdJt9iZJa";
        client_secret = "$__file{${config.sops.secrets."obs_auth_secret_key".path}}";
        scopes = "openid email profile";
        auth_url = "https://auth.dd-ix.net/application/o/authorize/";
        token_url = "https://auth.dd-ix.net/application/o/token/";
        api_url = "https://auth.dd-ix.net/application/o/userinfo/";
        role_attribute_path = "contains(groups, 'DDIX-Board') && 'Admin' || contains(groups, 'DDIX-Tech') && 'Editor' || 'Viewer'";
      };
    };
    provision = {
      enable = true;
      datasources = {
        deleteDatasources = [{ name = "svc-prom01"; }];
        settings.datasources = [{
          name = "svc-prom01";
          url = "https://svc-prom01.dd-ix.net:443";
          uid = "svc-prom01";
          type = "prometheus";
          access = "proxy";
          enable = true;
        }];
      };
    };
  };
}
