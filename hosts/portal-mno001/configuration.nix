{ ... }:
{
  dd-ix.microvm = {
    enable = true;

    mem = 2048;
    vcpu = 2;

    hostName = "portal";
    mac = "e2:b4:cb:12:f4:c1";
    vlan = "svc";

    v6Addr = "2a01:7700:80b0:6001::1/64";
  };

  networking.firewall.allowedTCPPorts = [ 80 ];

  system.stateVersion = "23.11";
}
