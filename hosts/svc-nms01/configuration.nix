{
  dd-ix = {
    hostName = "svc-nms01";

    microvm = {
      mem = 2048;
      vcpu = 2;
    };

    acme = [{
      name = "nms.dd-ix.net";
      group = "nginx";
    }];

    mariadb = [ "librenms" ];

    monitoring = {
      enable = true;
    };
  };

  system.stateVersion = "23.11";
}
