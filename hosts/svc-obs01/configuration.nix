{ ... }:
let
  addr = "2a01:7700:80b0:6001::11";
in
{
  dd-ix = {
    useFpx = true;
    hostName = "svc-obs01";

    microvm = {
      enable = true;

      mem = 2048;
      vcpu = 2;
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
