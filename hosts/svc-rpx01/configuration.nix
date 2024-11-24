{ lib, config, ... }:
{
  dd-ix = {
    hostName = "svc-rpx01";

    microvm = {
      enable = true;

      mem = 2048;
      vcpu = 2;

      v4Addr = "212.111.245.178/29";
    };

    monitoring = {
      enable = true;
    };
  };
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.nginx = {
    enable = true;

    virtualHosts."_".locations."/".return = "301 https://$host$request_uri";

    streamConfig =
      let
        buildMapping = host: map (domain: "${domain} [${host.networking.addr}]:443;") host.rpx.domains;
        mappings = lib.flatten (map buildMapping (lib.attrValues config.dd-ix.hosts));
      in
      ''
        map $ssl_preread_server_name $targetBackend {
          ${lib.strings.concatStringsSep "\n" mappings}
        }

        server {
          listen 443;
          listen [::]:443;

          proxy_connect_timeout 3s;
          proxy_timeout 3m;

          proxy_pass $targetBackend;
          proxy_protocol on;
          ssl_preread on;
        }
      '';
  };

  system.stateVersion = "23.11";
}
