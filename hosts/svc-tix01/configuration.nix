{ config, ... }:
let
  addr = "2a01:7700:80b0:6001::16";
in
{
  dd-ix = {
    useFpx = true;
    hostName = "svc-tix01";

    microvm = {
      enable = true;

      mem = 2048;
      vcpu = 2;

      mac = "02:1f:0a:4f:5a:27";
      vlan = "s";

      v6Addr = "${addr}/64";
    };

    acme = [{
      name = "tickets.dd-ix.net";
      group = "nginx";
    }];

    rpx = {
      domains = [ "tickets.dd-ix.net" ];
      addr = "[${addr}]:443";
    };

    postgres = [ config.services.pretix.settings.database.name ];

    monitoring = {
      enable = true;
    };
  };

  system.stateVersion = "24.05";
}
