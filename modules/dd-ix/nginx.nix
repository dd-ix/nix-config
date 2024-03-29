{ ... }:

let
  headers = ''
    # Permissions Policy - gps only
    add_header Permissions-Policy "geolocation=()";

    # Minimize information leaked to other domains
    add_header 'Referrer-Policy' 'origin-when-cross-origin';

    # Disable embedding as a frame
    # add_header X-Frame-Options DENY;

    # Prevent injection of code in other mime types (XSS Attacks)
    #add_header X-Content-Type-Options nosniff;

    # Enable XSS protection of the browser.
    # May be unnecessary when CSP is configured properly (see above)
    #add_header X-XSS-Protection "1; mode=block";

    # STS
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    # real ip
    set_real_ip_from 2a01:7700:80b0:6000::443;
    real_ip_header proxy_protocol;
  '';
in
{
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  services.nginx = {
    recommendedZstdSettings = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedBrotliSettings = true;
    commonHttpConfig = headers;
  };
}
