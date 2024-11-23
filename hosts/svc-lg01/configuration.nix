{ ... }:
let
  addr = "2a01:7700:80b0:6001::10";
in
{
  dd-ix = {
    useFpx = true;
    hostName = "svc-lg01";

    microvm = {
      enable = true;

      mem = 2048;
      vcpu = 2;
    };

    acme = [{
      name = "lg.dd-ix.net";
      group = "nginx";
    }];

    rpx = {
      domains = [ "lg.dd-ix.net" ];
      addr = "[${addr}]:443";
    };

    monitoring = {
      enable = true;
    };
  };

  system.stateVersion = "23.11";
}
