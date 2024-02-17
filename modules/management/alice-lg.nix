{ self, lib, config, pkgs, ... }:
let
  listen_addr = "[::1]:7340";
  route_server = [
    "01"
    "02"
  ];
in
{
  services = {
    alice-lg = {
      enable = true;
      package = pkgs.callPackage ../../resources/alice.nix {};
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
          (num: {
            "source.rs${num}-v4" = {
              name = "rs${num}.dd-ix.net (IPv4)";
            };
            "source.rs${num}-v4.birdwatcher" = {
              # https://github.com/alice-lg/alice-lg/blob/main/etc/alice-lg/alice.example.conf#L210-L214
              api = "http://[2a01:7700:80b0:40${num}::2]:29184";
              type = "multi_table";
            };
            "source.rs-${num}-v6" = {
              name = "rs${num}.dd-ix.net (IPv6)";
            };
            "source.rs-${num}-v6.birdwatcher" = {
              # https://github.com/alice-lg/alice-lg/blob/main/etc/alice-lg/alice.example.conf#L210-L214
              api = "http://[2a01:7700:80b0:40${num}::2]:29184";
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
