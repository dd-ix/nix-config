{
  dd-ix = {
    hostName = "svc-lists01";
    useFpx = true;

    microvm = {
      mem = 2048;
      vcpu = 2;
    };

    acme = [{
      name = "lists.dd-ix.net";
      group = "nginx";
    }];

    postgres = [ "mailman" "mailman_web" ];

    monitoring = {
      enable = true;
    };
  };

  system.stateVersion = "23.11";
}
