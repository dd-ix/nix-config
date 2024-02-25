{ ... }:
let
  addr = "2a01:7700:80b0:6001::7";
in
{
  dd-ix = {
    useFpx = true;

    microvm = {
      enable = true;

      mem = 2048;
      vcpu = 2;

      hostName = "svc-dcim01";
      mac = "02:1f:0a:4f:5a:26";
      vlan = "s";

      v6Addr = "${addr}/64";
    };

    acme = [{
      name = "dcim.dd-ix.net";
      group = "nginx";
    }];

    rpx = {
      domains = [ "dcim.dd-ix.net" ];
      addr = "[${addr}]:443";
    };

    postgres = [ "netbox" ];

    monitoring = {
      enable = true;
    };
  };

  system.stateVersion = "23.11";
}
