{ pkgs, ... }:
{
  dd-ix = {
    hostName = "svc-node01";

    microvm = {
      enable = true;

      mem = 1024 * 2;
      vcpu = 2;

      mac = "42:df:f0:70:02:03";
      vlan = "a";

      v6Addr = "2a01:7700:80b0:7002::3/64";
    };
  };

  system.stateVersion = "23.11";
}
