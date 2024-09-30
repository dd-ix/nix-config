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
            enable_neighbors_status_refresh = true;
          };

          theme.path = self + "/resources/alice";

          housekeeping = {
            interval = 5;
            force_release_memory = true;
          };

          pagination = {
            routes_filtered_page_size = 250;
            routes_accepted_page_size = 250;
            routes_not_exported_page_size = 250;
          };

          rpki = {
            enabled = true;
            valid = "57328:1000:1";
            unknown = "57328:1000:2";
            invalid = "57328:1000:4";
          };

          reject_reasons = {
            "57328:1101:3" = "Prefix is bogon";
            "57328:1101:4" = "Invalid ASN in AS_PATH";
            "57328:1101:5" = "Invalid AS_PATH length";
            "57328:1101:7" = "Invalid left-most ASN";
            "57328:1101:8" = "Invalid NEXT_HOP";
            "57328:1101:9" = "Prefix not in IRRDB AS-SETs";
            "57328:1101:10" = "Origin ASN not in IRRDB AS-SETs";
            "57328:1101:13" = "RPKI INVALID route";
            "57328:1101:14" = "Transit-free ASN in AS_PATH";
          };

          bgp_communities = {
            "57328:64512:11" = "Prefix is included in client's AS-SET";
            "57328:64512:10" = "Prefix is NOT included in client's AS-SET";
            "57328:64512:21" = "Origin ASN is included in client's AS-SET";
            "57328:64512:20" = "Origin ASN is NOT included in client's AS-SET";
            "57328:64512:31" = "Prefix matched by a RPKI ROA for the authorized origin ASN";
            "57328:64512:41" = "Route authorized soley because of a client white list entry";
            "57328:1000:1" = "RPKI Valid";
            "57328:1000:2" = "RPKI Unknown";
            "57328:1000:4" = "RPKI Invalid";
            "57328:1000:3" = "RPKI BGP Origin Validation not performed";
            "0:57328" = "Do not announce to any client";
            "57328:0:0" = "Do not announce to any client";
            "57328:peer_as" = "Announce to peer, even if tagged with the previous community";
            "57328:1:peer_as" = "Announce to peer, even if tagged with the previous community";
            "0:peer_as" = "Do not announce to peer";
            "57328:0:peer_as" = "Do not announce to peer";
            "65511:peer_as" = "Prepend the announcing ASN once to peer";
            "57328:101:peer_as" = "Prepend the announcing ASN once to peer";
            "65512:peer_as" = "Prepend the announcing ASN twice to peer";
            "57328:102:peer_as" = "Prepend the announcing ASN twice to peer";
            "65513:peer_as" = "Prepend the announcing ASN thrice to peer";
            "57328:103:peer_as" = "Prepend the announcing ASN thrice to peer";
            "65501:57328" = "Prepend the announcing ASN once to any";
            "57328:101:0" = "Prepend the announcing ASN once to any";
            "65502:57328" = "Prepend the announcing ASN twice to any";
            "57328:102:0" = "Prepend the announcing ASN twice to any";
            "65503:57328" = "Prepend the announcing ASN thrice to any";
            "57328:103:0" = "Prepend the announcing ASN thrice to any";
            "65281:peer_as" = "Add NO_EXPORT to peer";
            "57328:65281:peer_as" = "Add NO_EXPORT to peer";
            "65282:peer_as" = "Add NO_ADVERTISE to peer";
            "57328:65282:peer_as" = "Add NO_ADVERTISE to peer";
            "65520:0" = "Generic code: the route must be treated as rejected";
            "57328:65520:0" = "Generic code: the route must be treated as rejected";
            "57328:65520:1" = "Invalid AS_PATH length";
            "57328:65520:2" = "Prefix is bogon";
            "57328:65520:3" = "Prefix is in global blacklist";
            "57328:65520:4" = "Invalid AFI";
            "57328:65520:5" = "Invalid NEXT_HOP";
            "57328:65520:6" = "Invalid left-most ASN";
            "57328:65520:7" = "Invalid ASN in AS_PATH";
            "57328:65520:8" = "Transit-free ASN in AS_PATH";
            "57328:65520:9" = "Origin ASN not in IRRDB AS-SETs";
            "57328:65520:10" = "IPv6 prefix not in global unicast space";
            "57328:65520:11" = "Prefix is in client blacklist";
            "57328:65520:12" = "Prefix not in IRRDB AS-SETs";
            "57328:65520:13" = "Invalid prefix length";
            "57328:65520:14" = "RPKI INVALID route";
            "57328:65520:15" = "Never via route-servers ASN in AS_PATH";
            "57328:65520:65535" = "Unknown";
            "57328:1101:5" = "Invalid AS_PATH length";
            "57328:1101:3" = "Prefix is bogon";
            "57328:1101:8" = "Invalid NEXT_HOP";
            "57328:1101:7" = "Invalid left-most ASN";
            "57328:1101:4" = "Invalid ASN in AS_PATH";
            "57328:1101:14" = "Transit-free ASN in AS_PATH";
            "57328:1101:10" = "Origin ASN not in IRRDB AS-SETs";
            "57328:1101:9" = "Prefix not in IRRDB AS-SETs";
            "57328:1101:13" = "RPKI INVALID route";

            "57328:2000:1" = "DD-IX PoP CC";
            "57328:2000:2" = "DD-IX PoP C2";
          };
        }
        (lib.mkMerge (map
          (num: {
            "source.rs${num}_v6".name = "rs${num}.dd-ix.net (IPv6)";
            "source.rs${num}_v6.birdwatcher" = {
              api = "http://[2a01:7700:80b0:40${num}::2]:29186";
              type = "single_table";
              timezone = "Europe/Berlin";
              # go timeparsing: https://golang.org/pkg/time/#pkg-constants
              servertime = "2006-01-02T15:04:05Z07:00";
              servertime_short = "2006-01-02 15:04:05";
              servertime_ext = "2006-01-02 15:04:05";
            };
            "source.rs${num}_v4".name = "rs${num}.dd-ix.net (IPv4)";
            "source.rs${num}_v4.birdwatcher" = {
              api = "http://[2a01:7700:80b0:40${num}::2]:29184";
              type = "single_table";
              timezone = "Europe/Berlin";
              # go timeparsing: https://golang.org/pkg/time/#pkg-constants
              servertime = "2006-01-02T15:04:05Z07:00";
              servertime_short = "2006-01-02 15:04:05";
              servertime_ext = "2006-01-02 15:04:05";
            };
          })
          route_server))
      ];
    };

    nginx = {
      enable = true;
      virtualHosts."lg.${config.dd-ix.domain}" = {
        listen = [{
          addr = "[::]:443";
          proxyProtocol = true;
          ssl = true;
        }];

        onlySSL = true;
        useACMEHost = "lg.${config.dd-ix.domain}";

        locations."/".proxyPass = "http://${listen_addr}";
      };
    };
  };

  environment .etc."alice-lg/alice.conf".source = lib.mkForce (pkgs.writeText "alice.conf" ''
    ${lib.generators.toINI {} config.services.alice-lg.settings}
  
    [neighbors_columns]
    address = "Neighbor";
    asn = "ASN";
    state = "State";
    Uptime = "Last State Change";
    Description = "Description";
    routes_received = "Received";
    routes_accepted = "Accepted";
    routes_filtered = "Filtered";
    routes_exported = "Exported";
    
    [routes_columns]
    flags = "";
    network = "Network";
    gateway = "Next-Hop";
    bgp.as_path = "AS Path";
    metric = "Local Pref.";
    bgp.med = "MED";
    bgp.origin = "Origin";
    age = "Age";
    
    [lookup_columns]
    flags = "";
    network = "Network";
    gateway = "Next-Hop";
    ASPath = "AS Path";
    neighbor.asn = "ASN";
    neighbor.description = "Neighbor";
    routeserver.name = "RS";
  '');
}
