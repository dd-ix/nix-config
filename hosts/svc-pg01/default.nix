{
  imports = [
    ./postgres.nix
  ];

  dd-ix = {
    useFpx = true;
    hostName = "svc-pg01";

    microvm = {
      mem = 1024 * 4;
      vcpu = 4;
    };

    acme = [{ name = "svc-pg01.dd-ix.net"; }];

    monitoring = {
      enable = true;
    };
  };

  system.stateVersion = "23.11";
}
