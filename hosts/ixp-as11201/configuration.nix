{ ... }:
let
  addr = "2a01:7700:80b0:6001::11";
in
{
  dd-ix = {
    useFpx = true;

    microvm = {
      enable = true;

      mem = 2048;
      vcpu = 2;

      hostName = "ixp-as11201";
      mac = "62:7a:2e:2f:68:66";
      vlan = "s";

      v6Addr = "${addr}/64";
    };
  };

  networking.ifstate.settings.namespaces.ixp-peering.interfaces = [{
    name = "any112";
    link.kind = "dummy";
    addresses = [
      "192.175.48.1/32" #  prisoner.iana.org (anycast)
      "2620:4f:8000::1/128" #  prisoner.iana.org (anycast)
      "192.175.48.6/32" #  blackhole-1.iana.org (anycast)
      "2620:4f:8000::6/128" #  blackhole-1.iana.org (anycast)
      "192.175.48.42/32" #  blackhole-2.iana.org (anycast)
      "2620:4f:8000::42/128" #  blackhole-2.iana.org (anycast)
      "192.31.196.1/32" #  blackhole.as112.arpa (anycast)
      "2001:4:112::1/128" #  blackhole.as112.arpa (anycast)
    ];
  }];

  systemd.services.knot.serviceConfig.NetworkNamespacePath = "/var/run/netns/ixp-peering";

  boot.kernel.sysctl = {
    # this machine should not participate in SLAAC
    "net.ipv6.conf.all.accept_ra" = 0;
    "net.ipv6.conf.default.accept_ra" = 0;
    "net.ipv6.conf.all.autoconf" = 0;
    "net.ipv6.conf.default.autoconf" = 0;
    # no redirects nor evil RH0
    "net.ipv6.conf.all.ipv6.accept_redirects" = 0;
    "net.ipv6.conf.default.ipv6.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_source_route" = 0;
    "net.ipv6.conf.default.accept_source_route" = 0;
    # no forwarding
    "net.ipv6.conf.all.forwarding" = 0;
    "net.ipv6.conf.default.forwarding" = 0;


    # no redirects nor source route
    "net.ipv4.cong.all.accept_redirects" = 0;
    "net.ipv4.cong.default.accept_redirects" = 0;
    "net.ipv4.cong.all.send_redirects" = 0;
    "net.ipv4.cong.default.send_redirects" = 0;
    "net.ipv4.cong.all.accept_source_route" = 0;
    "net.ipv4.cong.default.accept_source_route" = 0;
    # handle arp requests strict
    "net.ipv4.cong.all.arp_ignore" = 1;
    "net.ipv4.cong.default.arp_ignore" = 1;
    "net.ipv4.cong.all.arp_notify" = 1;
    "net.ipv4.cong.default.arp_notify" = 1;
    # do strict rp filtering
    "net.ipv4.cong.all.rp_filter" = 1;
    "net.ipv4.cong.default.rp_filter" = 1;
    # no forwarding
    "net.ipv4.cong.all.forwarding" = 0;
    "net.ipv4.cong.default.forwarding" = 0;
  };

  system.stateVersion = "23.11";
}
