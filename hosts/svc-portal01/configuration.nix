{ ... }:
{
  dd-ix = {
    microvm = {
      enable = true;

      mem = 2048;
      vcpu = 2;

      hostName = "svc-portal01";
      mac = "e2:b4:cb:12:f4:c1";
      vlan = "s";

      v6Addr = "2a01:7700:80b0:6001::2/64";
    };

    acme = {
      enable = true;
      domain = "portal.dd-ix.net";
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];

  system.stateVersion = "23.11";
}
