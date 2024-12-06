{ ... }:
{
  dd-ix = {
    useFpx = true;

    hostName = "svc-prom02";
    microvm = {
      enable = true;

      mem = 1024 * 2;
      vcpu = 4;
    };

    acme = [{
      name = "svc-prom02.dd-ix.net";
      group = "nginx";
    }];

    monitoring = {
      enable = true;
    };
  };

  system.stateVersion = "23.11";
}
