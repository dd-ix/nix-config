{ lib, config, ... }:

let
  enable = config.services.nginx.enable;
  headers = ''
    # Permissions Policy - gps only
    more_set_headers "Permissions-Policy: geolocation=()";

    # Minimize information leaked to other domains
    more_set_headers "Referrer-Policy: origin-when-cross-origin";

    # Disable embedding as a frame
    # add_header X-Frame-Options DENY;

    # Prevent injection of code in other mime types (XSS Attacks)
    #add_header X-Content-Type-Options nosniff;

    # Enable XSS protection of the browser.
    # May be unnecessary when CSP is configured properly (see above)
    #add_header X-XSS-Protection "1; mode=block";

    # STS
    more_set_headers "Strict-Transport-Security: max-age=31536000; includeSubDomains";

    # real ip
    set_real_ip_from 2a01:7700:80b0:6000::443;
    real_ip_header proxy_protocol;
  '';
in
{
  networking.firewall.allowedTCPPorts = lib.mkIf enable [ 80 443 ];
  services = {
    nginx = {
      recommendedZstdSettings = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedBrotliSettings = true;
      commonServerConfig = headers;
    };
    prometheus.exporters.nginxlog = lib.mkIf enable {
      enable = true;
      group = "nginx";
      openFirewall = true;
      settings.namespaces = [{
        name = "nginx";
        source.files = [ "/var/log/nginx/access.log" ];
        # default value extracted from:
        # https://nginx.org/en/docs/http/ngx_http_log_module.html#log_format
        format = "$remote_addr - $remote_user [$time_local] \"$request\" $status $body_bytes_sent \"$http_referer\" \"$http_user_agent\"";
      }];
    };
  };
}
