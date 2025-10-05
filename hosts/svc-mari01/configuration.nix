{ config, ... }:

{
  dd-ix = {
    useFpx = true;
    hostName = "svc-mari01";

    microvm = {
      enable = true;

      mem = 2048;
      vcpu = 2;
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
