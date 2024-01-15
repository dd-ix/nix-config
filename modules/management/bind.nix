{ self, ... }:
let
  # IBH authorative nameservers
  # (IPv4 only as mno01 does not have IPv6, yet)
  ibh_ans_ip = [
    # ans-01.ibh.de
    "212.111.228.50"
    "2a01:7700:0:1035::1:50"
    # ans-02.ibh.net
    "193.36.123.50"
    "2a01:7700:0:1036::1:50"
    # ans-03.ibh.de
    "195.30.105.203"
    "2001:608:c00:10::1:138"
    # ans-04.ibh.services
    "167.235.139.88"
    "2a01:4f8:c0c:74b9::1"
    # ans-05.ibh.net
    "65.109.1.68"
    "2a01:4f9:c012:61fd::1"
  ];
in
{
  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  services.bind = {
    enable = true;

    # cannot talk to root ns (firewall)
    forward = "only";

    zones = {
      "dd-ix.net" = {
        master = true;
        file = self + "/resources/dd-ix.net.zone";
        slaves = ibh_ans_ip;
      };

      # ipv4 pa
      "176.245.111.212.in-addr.arpa" = {
        master = true;
        file = self + "/resources/176.245.111.212.in-addr.arpa";
        slaves = ibh_ans_ip;
      };

      # ipv6 pa
      "0.b.0.8.0.0.7.7.1.0.a.2.ip6.arpa" = {
        master = true;
        file = self + "/resources/0.b.0.8.0.0.7.7.1.0.a.2.ip6.arpa.zone";
        slaves = ibh_ans_ip;
      };
    };

    extraOptions = ''
      # this is hidden primary only, no recursive lookups allowed
      recursion no;

      # obscure bind9 chaos version queries
      version "DD-IX Authorative Name Server";

      # track stats on zones
      zone-statistics yes;
    '';
  };
}
