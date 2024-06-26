{ config, ... }:
let
  addr = "2a01:7700:80b0:6001::12";
in
{
  dd-ix = {
    useFpx = true;
    hostName = "svc-mari01";

    microvm = {
      enable = true;

      mem = 2048;
      vcpu = 2;

      mac = "e2:6c:c7:b6:fa:27";
      vlan = "s";

      v6Addr = "${addr}/64";
    };

    acme = [{
      name = "svc-mari01.dd-ix.net";
      group = config.systemd.services.mysql.serviceConfig.Group;
    }];

    monitoring = {
      enable = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 3306 ];

  system.stateVersion = "23.11";
}
