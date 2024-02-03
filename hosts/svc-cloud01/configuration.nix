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
      mac = "e2:d0:2f:67:dd:ae";
      vlan = "s";

      v6Addr = "${addr}/64";
    };

    acme = [{
      name = "cloud.dd-ix.net";
      group = "nginx";
    }];

    rpx = {
      domains = [ "cloud.dd-ix.net" ];
      addr = "[${addr}]:443";
    };

    postgres = [ "nextcloud" ];
  };

  system.stateVersion = "23.11";
}
