{ ... }:
let
  addr = "2a01:7700:80b0:6001::6";
in
{
  dd-ix = {
    useFpx = true;

    microvm = {
      enable = true;

      mem = 4096;
      vcpu = 4;

      hostName = "svc-cloud01";
      mac = "e2:d0:2f:67:dd:ae";
      vlan = "s";

      v6Addr = "${addr}/64";
      v4Addr = "10.96.1.6/24";
    };

    acme = [
      { name = "cloud.dd-ix.net"; group = "nginx"; }
      { name = "office.dd-ix.net"; group = "nginx"; }
    ];

    rpx = {
      domains = [ "cloud.dd-ix.net" "office.dd-ix.net" ];
      addr = "[${addr}]:443";
    };

    postgres = [ "nextcloud" "onlyoffice" ];
  };

  system.stateVersion = "23.11";
}
