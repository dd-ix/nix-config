{
  dd-ix = {
    useFpx = true;
    hostName = "svc-obs01";

    microvm = {
      enable = true;

      mem = 2048;
      vcpu = 2;
    };

    acme = [{
      name = "obs.dd-ix.net";
      group = "nginx";
    }];

    postgres = [ "grafana" ];

    monitoring = {
      enable = true;
    };
  };

  system.stateVersion = "23.11";
}
