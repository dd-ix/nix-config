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

    microvm.shares = [{
      source = "/nix/store";
      mountPoint = "/nix/.ro-store";
      tag = "store";
      proto = "virtiofs";
      socket = "store.socket";
    }];
  };

  systemd.network.networks = {
    "10-lan" = {
      matchConfig.MACAddress = mac;
      addresses = [
        { addressConfig.Address = "212.111.245.179/29"; }
        { addressConfig.Address = "2a01:7700:80b0:6000::53/64"; }
      ];
      routes = [
        { routeConfig.Gateway = "212.111.245.177/29"; }
        { routeConfig.Gateway = "fe80::defa/64"; }
      ];
      linkConfig.RequiredForOnline = "routable";
    };
  };

  system.stateVersion = "23.11";
}