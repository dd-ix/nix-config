{ pkgs, config, lib, ... }:
let
  # IBH authorative nameservers
  # (IPv4 only as mno01 does not have IPv6, yet)
  ibh_ans_ip = [
    # ans-01.ibh.de
    "212.111.228.50"
    # ans-02.ibh.net
    "193.36.123.50"
    # ans-03.ibh.de
    "195.30.105.203"
    # ans-04.ibh.services
    "167.235.139.88"
    # ans-05.ibh.net
    "65.109.1.68"
  ];

  # zone file dirname
  file_dir = "/etc/bind/db";
in
{
  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  services.bind = {
    enable = true;

    zones = {
      # reverse zone for IX IPv4
      "120.36.193.in-addr.arpa" = {
        master = true;
        file = "${file_dir}/120.36.193.in-addr.arpa";
        slaves = ibh_ans_ip;
        allowQuery = ibh_ans_ip ++ [ "127.0.0.0/8" "::1/128" ];
      };

      # reverse zone for IX IPv6
      "8.1.d.d.9.1.0.0.8.f.7.0.1.0.0.2.ip6.arpa" = {
        master = true;
        file = "${file_dir}/8.1.d.d.9.1.0.0.8.f.7.0.1.0.0.2.ip6.arpa";
        slaves = ibh_ans_ip;
        allowQuery = ibh_ans_ip ++ [ "127.0.0.0/8" "::1/128" ];
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
