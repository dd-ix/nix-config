{ pkgs, ... }:
let
  dd-empty = pkgs.writeText "db.dd-empty" ''
    $TTL    1W
    @  IN  SOA  prisoner.iana.org. hostmaster.root-servers.org. (
                                   1       ; serial number
                                   1W      ; refresh
                                   1M      ; retry
                                   1W      ; expire
                                   1W )    ; negative caching TTL

           NS     blackhole-1.iana.org.
           NS     blackhole-2.iana.org.
  '';
  dr-empty = pkgs.writeText "db.dr-empty" ''
    $TTL    1W
    @  IN  SOA  blackhole.as112.arpa. noc.dns.icann.org. (
                                   1       ; serial number
                                   1W      ; refresh
                                   1M      ; retry
                                   1W      ; expire
                                   1W )    ; negative caching TTL
           NS     blackhole.as112.arpa.
  '';
  hostname-as112-net = pkgs.writeText "db.hostname.as112.net" ''
    $TTL    1W
    @       SOA     ixp-as11201.dd-ix.net. noc.dd-ix.net. (
                            1               ; serial number
                            1W              ; refresh
                            1M              ; retry
                            1W              ; expire
                            1W )            ; negative caching TTL

            NS      blackhole-1.iana.org.
            NS      blackhole-2.iana.org.
   
            TXT     "DD-IX Dresden Internet Exchange e.V." "Dresden, Germany"
            TXT     "See http://www.as112.net/ for more information."
            TXT     "Website: https://dd-ix.net/"
   
            LOC     51 0 40.143 N 13 42 9.582 E 239m 10m 100m 10m
  '';
  hostname-as112-arpa = pkgs.writeText "db.hostname.as112.arpa" ''
    $TTL    1W
    @       SOA     ixp-as11201.dd-ix.net. noc.dd-ix.net. (
                            1               ; serial number
                            1W              ; refresh
                            1M              ; retry
                            1W              ; expire
                            1W )            ; negative caching TTL

            NS      blackhole.as112.arpa.

            TXT     "DD-IX Dresden Internet Exchange e.V." "Dresden, Germany"
            TXT     "See http://www.as112.net/ for more information."
            TXT     "Website: https://dd-ix.net/"
   
            LOC     51 0 40.143 N 13 42 9.582 E 239m 10m 100m 10m
  '';
in
{
  services.knot = {
    enable = true;
    settings = {
      server.listen = [
        "0.0.0.0@53"
        "::@53"
      ];

      mod-stats = [{
        id = "custom";
        request-protocol = false;
        server-operation = false;
        request-bytes = false;
        response-bytes = false;
        edns-presence = false;
        flag-presence = false;
        response-code = false;
        request-edns-option = false;
        response-edns-option = false;
        reply-nodata = false;
        query-type = true;
        query-size = false;
        reply-size = false;
      }];

      template = [{
        id = "default";
        global-module = "mod-stats/custom";
      }];

      zone = {
        # Direct Delegation AS112 Service
        # RFC 1918
        "10.in-addr.arpa" = { file = dd-empty; };
        "16.172.in-addr.arpa" = { file = dd-empty; };
        "17.172.in-addr.arpa" = { file = dd-empty; };
        "18.172.in-addr.arpa" = { file = dd-empty; };
        "19.172.in-addr.arpa" = { file = dd-empty; };
        "20.172.in-addr.arpa" = { file = dd-empty; };
        "21.172.in-addr.arpa" = { file = dd-empty; };
        "22.172.in-addr.arpa" = { file = dd-empty; };
        "23.172.in-addr.arpa" = { file = dd-empty; };
        "24.172.in-addr.arpa" = { file = dd-empty; };
        "25.172.in-addr.arpa" = { file = dd-empty; };
        "26.172.in-addr.arpa" = { file = dd-empty; };
        "27.172.in-addr.arpa" = { file = dd-empty; };
        "28.172.in-addr.arpa" = { file = dd-empty; };
        "29.172.in-addr.arpa" = { file = dd-empty; };
        "30.172.in-addr.arpa" = { file = dd-empty; };
        "31.172.in-addr.arpa" = { file = dd-empty; };
        "168.192.in-addr.arpa" = { file = dd-empty; };
        # RFC 6890
        "254.169.in-addr.arpa" = { file = dd-empty; };
        # DNAME redirection AS112 Service
        "empty.as112.arpa" = { file = dr-empty; };
        # Also answer authoritatively for the HOSTNAME.AS112.NET and
        # HOSTNAME.AS112.ARPA zones, which contain data of operational
        # relevance.
        "hostname.as112.net" = { file = hostname-as112-net; };
        "hostname.as112.arpa" = { file = hostname-as112-arpa; };
      };
    };
  };

  services.prometheus.exporters.knot = {
    enable = true;
    listenAddress = "::";
    openFirewall = true;
    extraFlags = [
      "--no-meminfo"
      "--no-zone-stats"
      "--no-zone-status"
      "--no-zone-timers"
      "--no-zone-serial"
    ];
  };
}
