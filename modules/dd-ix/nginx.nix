{ lib, config, ... }:

let
  cfg = config.services.nginx;
in
{
  networking.firewall.allowedTCPPorts = lib.mkIf cfg.enable [ 80 443 ];
  services = {
    nginx = {
      recommendedZstdSettings = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedBrotliSettings = true;
      commonHttpConfig = ''
        set_real_ip_from 2a01:7700:80b0:6000::443;
        real_ip_header proxy_protocol;
      '';
    };
    prometheus.exporters.nginxlog = lib.mkIf cfg.enable {
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
