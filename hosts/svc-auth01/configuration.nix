{ lib, ... }:
let
  addr = "2a01:7700:80b0:6001::4";
in
{
  dd-ix = {
    useFpx = true;
    hostName = "svc-auth01";

    microvm = {
      enable = true;

      mem = 2048;
      vcpu = 2;
    };

    acme = [{
      name = "auth.dd-ix.net";
      group = "nginx";
    }];

    rpx = {
      domains = [ "auth.dd-ix.net" ];
      addr = "[${addr}]:443";
    };

    postgres = [ "authentik" ];

    monitoring = {
      enable = true;
    };
  };

  networking.firewall.allowedUDPPorts = [ 1812 ];

  # https://github.com/goauthentik/authentik/issues/3005
  time.timeZone = lib.mkForce "UTC";

  system.stateVersion = "23.11";
}
