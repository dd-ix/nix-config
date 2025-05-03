{ lib, config, ... }:

let
  blockedNetworks = [
    # cheapy.host LLC - mailman spam - 2025-04-12
    "196.251.69.0/24"
    "196.251.70.0/24"
    "196.251.71.0/24"
    "196.251.72.0/24"
    "196.251.73.0/24"
    "196.251.80.0/24"
    "196.251.81.0/24"
    "196.251.83.0/24"
    "196.251.84.0/24"
    "196.251.85.0/24"
    "196.251.86.0/24"
    "196.251.87.0/24"
    "196.251.88.0/24"
    "196.251.89.0/24"
    "196.251.90.0/24"
    "196.251.91.0/24"
    # Atomic Networks LLC - mailman spam 2025-05-01
    "23.146.184.0/24"
    "45.61.170.0/24"
    "64.49.8.0/24"
    "64.49.9.0/24"
    "82.153.134.0/24"
    "166.1.173.0/24"
    "204.137.14.0/24"
    "2602:fc2f:100::/40"
    "2602:fc2f:f00::/48"
  ];

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

    ${lib.concatStringsSep "\n" (map (network: "deny ${network};") blockedNetworks)}
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

  networking.hosts = {
    # add all nginx hosts as localhost to hosts file, avoid connection through rpx when using local services
    "::1" = builtins.attrNames config.services.nginx.virtualHosts;
    "127.0.0.1" = builtins.attrNames config.services.nginx.virtualHosts;
  };
}
