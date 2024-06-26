{ ... }:
{
  dd-ix = {
    useFpx = true;

    hostName = "svc-prom01";

    microvm = {
      enable = true;

      mem = 1024 * 2;
      vcpu = 2;

      mac = "42:b3:bc:bb:11:b6";
      vlan = "a";

      v6Addr = "2a01:7700:80b0:7002::4/64";
    };

    acme = [{
      name = "svc-prom01.dd-ix.net";
      group = "nginx";
    }];

    monitoring = {
      enable = true;
    };
  };

  system.stateVersion = "23.11";
}
