{ config, ... }:

{
  virtualisation.docker.daemon.settings = {
    http-proxy = config.networking.proxy.httpProxy;
    https-proxy = config.networking.proxy.httpsProxy;
    no-proxy = config.networking.proxy.noProxy;
  };
}
