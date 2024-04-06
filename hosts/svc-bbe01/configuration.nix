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

      v6Addr = "2a01:7700:80b0:6001::14/64";
    };

    monitoring = {
      enable = true;
    };
  };

  system.stateVersion = "23.11";
}
