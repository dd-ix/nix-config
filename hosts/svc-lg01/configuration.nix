{
  dd-ix = {
    useFpx = true;
    hostName = "svc-lg01";

    microvm = {
      enable = true;

      mem = 2048;
      vcpu = 2;
    };

    acme = [{
      name = "lg.dd-ix.net";
      group = "nginx";
    }];

    monitoring = {
      enable = true;
    };
  };

  system.stateVersion = "23.11";
}
