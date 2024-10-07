{ ... }:

let
  addr = "2a01:7700:80b0:7002::7";
in
{
  dd-ix = {
    hostName = "svc-nms01";

    microvm = {
      enable = true;

      mem = 2048;
      vcpu = 2;

      mac = "22:0a:f1:39:17:69";
      vlan = "a";

      v6Addr = "${addr}/64";
    };

    acme = [{
      name = "nms.dd-ix.net";
      group = "nginx";
    }];

    rpx = {
      domains = [ "nms.dd-ix.net" ];
      addr = "[${addr}]:443";
    };

    mariadb = [ "librenms" ];

    monitoring = {
      enable = true;
    };
  };

  system.stateVersion = "23.11";
}
