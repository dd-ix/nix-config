{
  dd-ix = {
    hostName = "svc-log01";
    useFpx = true;

    microvm = {
      enable = true;

      mem = 1024 * 2;
      vcpu = 2;
    };

    acme = [{
      name = "svc-log01.dd-ix.net";
      group = "nginx";
    }];

    monitoring = {
      enable = true;
    };
  };

  system.stateVersion = "25.05";
}
