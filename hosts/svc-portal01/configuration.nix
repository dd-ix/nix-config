{
  dd-ix = {
    useFpx = true;
    hostName = "svc-portal01";

    microvm = {
      mem = 2048;
      vcpu = 2;

      v4Addr = "10.96.1.2/24";
    };

    acme = [{
      name = "portal.dd-ix.net";
      group = "nginx";
    }];

    mariadb = [ "ixp_manager" ];

    monitoring = {
      enable = true;
    };
  };

  system.stateVersion = "23.11";
}
