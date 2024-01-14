{ ... }:
let
  mac = "a2:18:9f:dc:4d:16";
in
{
  microvm = {
    hypervisor = "cloud-hypervisor";
    mem = 2048;
    vcpu = 2;

    interfaces = [{
      type = "tap";
      id = "vm-inet-ns";
      mac = mac;
    }];

    shares = [
      {
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
        tag = "store";
        proto = "virtiofs";
        socket = "store.socket";
      }
      {
        source = "/var/lib/microvms/ns-mno001/var/log";
        mountPoint = "/var/log";
        tag = "var";
        proto = "virtiofs";
        socket = "var.socket";
      }
    ];
  };

  networking.nameservers = [
    # rns-01.ibh.net
    "212.111.228.53"
    "2a01:7700:0:1035::1:53"
    # rns-02.ibh.net
    "193.36.123.53"
    "2a01:7700:0:1036::1:53"
  ];

  systemd.network.networks = {
    "10-lan" = {
      matchConfig.MACAddress = mac;
      addresses = [
        { addressConfig.Address = "212.111.245.179/29"; }
        { addressConfig.Address = "2a01:7700:80b0:6000::53/64"; }
      ];
      routes = [
        { routeConfig.Gateway = "212.111.245.177"; }
        { routeConfig.Gateway = "fe80::defa"; }
      ];
      linkConfig.RequiredForOnline = "routable";
    };
  };

  system.stateVersion = "23.11";
}
