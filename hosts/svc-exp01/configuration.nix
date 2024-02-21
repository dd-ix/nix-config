{ ... }:
{
  dd-ix = {
    useFpx = true;

    microvm = {
      enable = true;

      mem = 1024 * 2;
      vcpu = 2;

      hostName = "svc-exp01";
      mac = "d2:7b:c0:b2:42:0f";
      vlan = "im";

      v6Addr = "2a01:7700:80b0:4101::3/64";
    };

    acme = [{
      name = "svc-exp01.dd-ix.net";
      group = "nginx";
    }];
  };

  networking.firewall.allowedUDPPorts = [ 6343 ];

  system.stateVersion = "23.11";
}
