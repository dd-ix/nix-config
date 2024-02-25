{ ... }:
let
  addr = "2a01:7700:80b0:6001::13";
in
{
  dd-ix = {
    useFpx = true;

    microvm = {
      enable = true;

      mem = 2048;
      vcpu = 2;

      hostName = "svc-web01";
      mac = "82:5a:db:e0:53:63";
      vlan = "s";

      v6Addr = "${addr}/64";
    };

    acme = [
      {
        name = "dd-ix.net";
        group = "nginx";
      }
      {
        name = "www.dd-ix.net";
        group = "nginx";
      }
      {
        name = "content.dd-ix.net";
        group = "nginx";
      }
    ];

    rpx = {
      domains = [ "dd-ix.net" "www.dd-ix.net" "content.dd-ix.net" ];
      addr = "[${addr}]:443";
    };

    monitoring = {
      enable = true;
    };
  };

  system.stateVersion = "23.11";
}
