{ ... }:
{
  dd-ix = {
    useFpx = true;

    hostName = "svc-prom02";
    microvm = {
      enable = true;

      mem = 1024 * 2;
      vcpu = 2;

      mac = "42:f7:f7:72:24:0f";
      vlan = "a";

      v6Addr = "2a01:7700:80b0:7002::5/64";
    };

    acme = [{
      name = "svc-prom02.dd-ix.net";
      group = "nginx";
    }];

    monitoring = {
      enable = true;
    };
  };

  system.stateVersion = "23.11";
}
