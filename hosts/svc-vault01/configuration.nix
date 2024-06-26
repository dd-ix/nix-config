{ ... }:
let
  addr = "2a01:7700:80b0:6001::9";
in
{
  dd-ix = {
    hostName = "svc-vault01";
    useFpx = true;

    microvm = {
      enable = true;

      mem = 2048;
      vcpu = 2;

      mac = "b2:a0:24:ba:e8:15";
      vlan = "s";

      v6Addr = "${addr}/64";
    };

    acme = [{
      name = "vault.dd-ix.net";
      group = "nginx";
    }];

    rpx = {
      domains = [ "vault.dd-ix.net" ];
      addr = "[${addr}]:443";
    };

    postgres = [ "vaultwarden" ];

    monitoring = {
      enable = true;
    };
  };

  system.stateVersion = "23.11";
}
