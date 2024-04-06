{ ... }:
{
  dd-ix = {
    useFpx = true;

    microvm = {
      enable = true;

      mem = 1024 * 2;
      vcpu = 2;

      hostName = "svc-bbe01";
      mac = "42:f3:bc:bb:11:b6";
      vlan = "a";

      v6Addr = "2a01:7700:80b0:7002::6/64";
    };

    acme = [{
      name = "svc-bbe01.dd-ix.net";
      group = "nginx";
    }];

    monitoring = {
      enable = true;
    };
  };

  system.stateVersion = "23.11";
}
