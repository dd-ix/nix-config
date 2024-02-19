{ ... }:
let
  addr = "2a01:7700:80b0:6001::6";
in
{
  dd-ix = {
    useFpx = true;

    microvm = {
      enable = true;

      mem = 2048;
      vcpu = 2;

      hostName = "svc-cloud01";
      mac = "62:7a:2e:2f:68:66";
      vlan = "s";

      v6Addr = "${addr}/64";
      v4Addr = "10.96.1.6/24";
    };
  };

  system.stateVersion = "23.11";
}
