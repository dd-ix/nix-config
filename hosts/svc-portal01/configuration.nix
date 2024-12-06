{ ... }:
let
  addr = "2a01:7700:80b0:6001::2";
in
{
  dd-ix = {
    useFpx = true;
    hostName = "svc-portal01";

    microvm = {
      enable = true;

      mem = 2048;
      vcpu = 2;

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

    mariadb = [ "ixp_manager" ];

    monitoring = {
      enable = true;
    };
  };

  system.stateVersion = "23.11";
}
