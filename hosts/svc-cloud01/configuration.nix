{ ... }:
let
  addr = "2a01:7700:80b0:6001::6";
in
{
  dd-ix = {
    useFpx = true;
    hostName = "svc-cloud01";

    microvm = {
      enable = true;

      mem = 4096;
      vcpu = 4;

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

    monitoring = {
      enable = true;
    };
  };

  system.stateVersion = "23.11";
}
