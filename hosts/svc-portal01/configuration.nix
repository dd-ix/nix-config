{ ... }:
let
  addr = "2a01:7700:80b0:6001::2";
in
{
  dd-ix = {
    useFpx = true;

    microvm = {
      enable = true;

      mem = 2048;
      vcpu = 2;

      hostName = "svc-portal01";
      mac = "e2:b4:cb:12:f4:c1";
      vlan = "s";

      v6Addr = "${addr}/64";
      v4Addr = "10.96.1.2/24";
    };

    acme = [{
      name = "portal.dd-ix.net";
      group = "nginx";
    }];

    rpx = {
      domains = [ "portal.dd-ix.net" ];
      addr = "[${addr}]:443";
    };
  };

  system.stateVersion = "23.11";
}
