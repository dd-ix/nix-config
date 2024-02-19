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

  system.stateVersion = "23.11";
}
