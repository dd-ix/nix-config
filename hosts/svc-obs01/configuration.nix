{ ... }:
let
  addr = "2a01:7700:80b0:6001::11";
in
{
  dd-ix = {
    useFpx = true;

    microvm = {
      enable = true;

      mem = 2048;
      vcpu = 2;

      hostName = "svc-obs01";
      mac = "62:9d:0f:8e:29:3f";
      vlan = "s";

      v6Addr = "${addr}/64";
    };

    acme = [{
      name = "obs.dd-ix.net";
      group = "nginx";
    }];

    rpx = {
      domains = [ "obs.dd-ix.net" ];
      addr = "[${addr}]:443";
    };

    postgres = [ "grafana" ];


    monitoring = {
      enable = true;
    };
  };

  system.stateVersion = "23.11";
}
