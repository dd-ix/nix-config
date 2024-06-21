{ ... }:
let
  addr = "2a01:7700:80b0:6001::15";
in
{
  dd-ix = {
    useFpx = true;
    hostName = "svc-orga01";

    microvm = {
      enable = true;

      mem = 4096;
      vcpu = 4;

      mac = "e2:d0:2f:67:dd:1e";
      vlan = "s";

      v6Addr = "${addr}/64";
      #v4Addr = "10.96.1.6/24";
    };

    acme = [
      { name = "orga.dd-ix.net"; group = "nginx"; }
    ];

    rpx = {
      domains = [ "orga.dd-ix.net" ];
      addr = "[${addr}]:443";
    };

    postgres = [ "openproject" ];

    monitoring = {
      enable = true;
    };
  };

  system.stateVersion = "23.11";
}
