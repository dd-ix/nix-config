{ config, ... }:
let
  addr = "2a01:7700:80b0:6001::5";
in
{
  dd-ix = {
    useFpx = true;
    hostName = "svc-pg01";

    microvm = {
      enable = true;

      mem = 2048;
      vcpu = 2;

      mac = "f2:8b:16:7e:6c:6b";
      vlan = "s";

      v6Addr = "${addr}/64";
    };

    acme = [{ name = "svc-pg01.dd-ix.net"; }];

    monitoring = {
      enable = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 443 ];

  system.stateVersion = "23.11";
}
