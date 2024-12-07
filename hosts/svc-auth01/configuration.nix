{ lib, ... }:

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
