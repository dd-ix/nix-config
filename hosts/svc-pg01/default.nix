{
  imports = [
    ./postgres.nix
  ];

  dd-ix = {
    useFpx = true;
    hostName = "svc-pg01";

    microvm = {
      enable = true;

      mem = 2048;
      vcpu = 2;
    };

    acme = [{ name = "svc-pg01.dd-ix.net"; }];

    monitoring = {
      enable = true;
    };
  };

  system.stateVersion = "23.11";
}
