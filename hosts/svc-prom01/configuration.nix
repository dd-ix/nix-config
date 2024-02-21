{ ... }:
{
  dd-ix = {
    useFpx = true;

    microvm = {
      enable = true;

      mem = 1024 * 2;
      vcpu = 2;

      hostName = "svc-prom01";
      mac = "42:b3:bc:bb:11:b6";
      vlan = "a";

      v6Addr = "2a01:7700:80b0:7002::4/64";
    };

    acme = [{
      name = "svc-prom01.dd-ix.net";
      group = "nginx";
    }];
  };

  system.stateVersion = "23.11";
}
