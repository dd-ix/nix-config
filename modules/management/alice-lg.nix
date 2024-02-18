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
      package = pkgs.callPackage ../../resources/alice.nix { };
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
            "source.rs${num}".name = "rs${num}.dd-ix.net";
            "source.rs${num}.birdwatcher" = {
              api = "http://[2a01:7700:80b0:40${num}::2]:29184";
              type = "multi_table";
              timezone = "Europe/Berlin";
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
