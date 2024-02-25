{ ... }:
let
  addr = "2a01:7700:80b0:6001::10";
in
{
  dd-ix = {
    useFpx = true;

    microvm = {
      enable = true;

      mem = 2048;
      vcpu = 2;

      hostName = "svc-lg01";
      mac = "82:cf:03:27:d8:8b";
      vlan = "s";

      v6Addr = "${addr}/64";
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
