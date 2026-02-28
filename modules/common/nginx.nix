# https://github.com/nix-community/srvos/blob/main/nixos/mixins/nginx.nix

{ lib, config, ... }:

{
  services.nginx = {
    recommendedBrotliSettings = lib.mkDefault true;
    recommendedGzipSettings = lib.mkDefault true;
    recommendedOptimisation = lib.mkDefault true;
    recommendedProxySettings = lib.mkDefault true;
    recommendedTlsSettings = lib.mkDefault true;

    sslDhparam = lib.mkIf config.services.nginx.enable config.security.dhparams.params.nginx.path;
  };

  security.dhparams = lib.mkIf config.services.nginx.enable {
    enable = true;
    params.nginx = { };
  };

  networking.hosts =
    let
      isHttpOrHttps = port: port == 443 || port == 80;
      localV4VirtualHosts = lib.filterAttrs
        (_: virtualHost:
          lib.any
            (listen: (isHttpOrHttps listen.port) && (listen.addr == "0.0.0.0" || listen.addr == "127.0.0.1") && !listen.proxyProtocol)
            virtualHost.listen
        )
        config.services.nginx.virtualHosts;
      localV6VirtualHosts = lib.filterAttrs
        (_: virtualHost:
          lib.any
            (listen: (isHttpOrHttps listen.port) && (listen.addr == "[::]" || listen.addr == "[::1]") && !listen.proxyProtocol)
            virtualHost.listen
        )
        config.services.nginx.virtualHosts;
      localV4Hosts = builtins.attrNames localV4VirtualHosts;
      localV6Hosts = builtins.attrNames localV6VirtualHosts;
    in
    {
      # add all nginx hosts as localhost to hosts file, avoid connection through rpx when using local services
      "127.0.0.1" = lib.mkIf (builtins.length localV4Hosts != 0) localV4Hosts;
      "::1" = lib.mkIf (builtins.length localV6Hosts != 0) localV6Hosts;
    };
}
