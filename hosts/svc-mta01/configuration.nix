{ ... }:
{
  dd-ix = {
    hostName = "svc-mta01";
    useFpx = true;

    microvm = {
      enable = true;

      mem = 2048;
      vcpu = 2;

      mac = "a2:18:9f:dc:4d:17";
      vlan = "i";

      v6Addr = "2a01:7700:80b0:6000::25/64";
      v4Addr = "212.111.245.180/29";
    };

    acme = [{
      name = "svc-mta01.dd-ix.net";
      group = "root";
    }];

    monitoring = {
      enable = true;
    };
  };

  system.stateVersion = "23.11";
}
