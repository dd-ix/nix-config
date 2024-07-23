{ ... }:
let
  addr = "2a01:7700:80b0:6001::8";
in
{
  dd-ix = {
    hostName = "svc-lists01";
    useFpx = true;

    microvm = {
      enable = true;

      mem = 2048;
      vcpu = 2;

      mac = "e2:7a:81:44:91:a3";
      vlan = "s";

      v6Addr = "${addr}/64";
    };

    acme = [{
      name = "lists.dd-ix.net";
      group = "nginx";
    }];

    rpx = {
      domains = [ "lists.dd-ix.net" ];
      addr = "[${addr}]:443";
    };

    postgres = [ "mailman" "mailman_web" ];

    monitoring = {
      enable = true;
    };
  };

  system.stateVersion = "23.11";
}
