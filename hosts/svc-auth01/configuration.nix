{ lib, ... }:
let
  addr = "2a01:7700:80b0:6001::4";
in
{
  dd-ix = {
    useFpx = true;

    microvm = {
      enable = true;

      mem = 2048;
      vcpu = 2;

      hostName = "svc-auth01";
      mac = "72:05:50:30:38:6d";
      vlan = "s";

      v6Addr = "${addr}/64";
    };

    acme = [{
      name = "auth.dd-ix.net";
      group = "nginx";
    }];

    rpx = {
      domains = [ "auth.dd-ix.net" ];
      addr = "[${addr}]:443";
    };
  };

  networking.firewall.allowedTCPPorts = [ 443 ];

  # https://github.com/goauthentik/authentik/issues/3005
  time.timeZone = lib.mkForce "UTC";

  system.stateVersion = "23.11";
}
