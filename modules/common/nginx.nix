# https://github.com/nix-community/srvos/blob/main/nixos/mixins/nginx.nix

{ lib, config, ... }:

{
  services.nginx = {
    recommendedBrotliSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    # Nginx sends all the access logs to /var/log/nginx/access.log by default.
    # instead of going to the journal!
    commonHttpConfig = "access_log syslog:server=unix:/dev/log;";

    sslDhparam = lib.mkIf config.services.nginx.enable config.security.dhparams.params.nginx.path;
  };

  security.dhparams = lib.mkIf config.services.nginx.enable {
    enable = true;
    params.nginx = { };
  };
}
