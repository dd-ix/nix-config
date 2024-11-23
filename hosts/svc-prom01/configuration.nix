{ ... }:
{
  dd-ix = {
    useFpx = true;

    hostName = "svc-prom01";

    microvm = {
      enable = true;

      mem = 1024 * 2;
      vcpu = 2;
    };

    acme = [{
      name = "svc-prom01.dd-ix.net";
      group = "nginx";
    }];

    monitoring = {
      enable = true;
    };
  };

  system.stateVersion = "23.11";
}
