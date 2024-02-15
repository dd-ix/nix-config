{ self, lib, config, ... }:
let
  listen_addr = "[::1]:7340";
  route_server = [
    "rs01"
    "rs02"
  ];
in
{
  services = {
    alice-lg = {
      enable = true;
      settings = lib.mkMerge [
        {
          server = {
            listen_http = "${listen_addr}";
            asn = 57328;
            enable_prefix_lookup = true;
          };
          theme.path = self + "/resources/alice";
        }
        (lib.mkMerge (map
          (name: {
            "source.${name}-v4" = {
              name = "${name}.dd-ix.net (IPv4)";
            };
            "source.${name}-v4.birdwatcher" = {
              # https://github.com/alice-lg/alice-lg/blob/main/etc/alice-lg/alice.example.conf#L210-L214
              api = "http://ixp-${name}.dd-ix.net:29184/";
              type = "multi_table";
            };
            "source.${name}-v6" = {
              name = "${name}.dd-ix.net (IPv6)";
            };
            "source.${name}-v6.birdwatcher" = {
              # https://github.com/alice-lg/alice-lg/blob/main/etc/alice-lg/alice.example.conf#L210-L214
              api = "http://ixp-${name}.dd-ix.net:29184/";
              type = "multi_table";
            };
          })
          route_server))
      ];
    };

    nginx = {
      enable = true;
      virtualHosts."lg.${config.deployment-dd-ix.domain}" = {
        listen = [{
          addr = "[::]:443";
          proxyProtocol = true;
          ssl = true;
        }];

        onlySSL = true;
        useACMEHost = "lg.${config.deployment-dd-ix.domain}";

        locations."/".proxyPass = "http://${listen_addr}";
      };
    };
  };
}
