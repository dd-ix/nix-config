{ ... }:
{
  dd-ix = {
    hostName = "svc-ns01";

    microvm = {
      enable = true;

      mem = 2048;
      vcpu = 2;

      mac = "a2:18:9f:dc:4d:16";
      vlan = "i";

      v6Addr = "2a01:7700:80b0:6000::53/64";
    };

    monitoring = {
      enable = true;
    };
  };

  system.stateVersion = "23.11";
}
