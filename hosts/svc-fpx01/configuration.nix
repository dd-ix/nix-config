{ ... }:
{
  dd-ix = {
    microvm = {
      enable = true;

      mem = 2048;
      vcpu = 2;

      hostName = "svc-fpx01";
      mac = "d2:9e:36:14:00:ec";
      vlan = "s";

      v6Addr = "2a01:7700:80b0:6001::3/64";
      v4Addr = "10.96.1.3/24";
    };
  };

  system.stateVersion = "23.11";
}
