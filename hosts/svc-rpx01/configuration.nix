{ self, lib, ... }:
{
  dd-ix = {
    microvm = {
      enable = true;

      mem = 2048;
      vcpu = 2;

      hostName = "svc-rpx01";
      mac = "32:08:69:71:62:9b";
      vlan = "i";

      v6Addr = "2a01:7700:80b0:6000::443/64";
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
        systems = lib.attrValues self.nixosConfigurations;
        rpxEnabled = system: (lib.length system.config.dd-ix.rpx.domains) != 0;
        rpxEnabledSystems = lib.filter rpxEnabled systems;
        buildMapping = system: let cfg = system.config.dd-ix.rpx; in map (domain: "${domain} ${cfg.addr};") cfg.domains;
        mappings = lib.flatten (map buildMapping rpxEnabledSystems);
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
