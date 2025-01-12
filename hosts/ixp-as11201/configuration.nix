{ config, ... }:

{
  dd-ix = {
    useFpx = true;
    monitoring = { enable = true; };
    hostName = "ixp-as11201";

    microvm = {
      enable = true;

      mem = 2048;
      vcpu = 2;
    };
  };

  # device in peering vlan
  microvm.devices = [{
    bus = "pci";
    path = "0000:06:00.0";
  }];

  networking.ifstate.settings.namespaces.ixp-peering = {
    # copy sysctl from default netns
    options.sysctl = config.networking.ifstate.settings.options.sysctl;
    interfaces = [
      {
        name = "any112";
        link = {
          state = "up";
          kind = "dummy";
        };
        addresses = [
          "192.175.48.1/24" #  prisoner.iana.org (anycast)
          "2620:4f:8000::1/48" #  prisoner.iana.org (anycast)
          "192.175.48.6/24" #  blackhole-1.iana.org (anycast)
          "2620:4f:8000::6/48" #  blackhole-1.iana.org (anycast)
          "192.175.48.42/24" #  blackhole-2.iana.org (anycast)
          "2620:4f:8000::42/48" #  blackhole-2.iana.org (anycast)
          "192.31.196.1/24" #  blackhole.as112.arpa (anycast)
          "2001:4:112::1/48" #  blackhole.as112.arpa (anycast)
        ];
      }
      {
        name = "ixp-peering";
        link = {
          state = "up";
          kind = "physical";
          permaddr = "40:f2:e9:2d:d6:6a";
        };
        addresses = [
          "2001:7f8:79::70:1/64"
          "193.201.151.70/26"
        ];
      }
    ];
  };

  systemd.services.knot.serviceConfig.NetworkNamespacePath = "/var/run/netns/ixp-peering";
  systemd.services.bird2.serviceConfig.NetworkNamespacePath = "/var/run/netns/ixp-peering";

  system.stateVersion = "23.11";
}
