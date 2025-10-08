{
  dd-ix = {
    hostName = "svc-bbe01";
    useFpx = true;

    microvm = {
      mem = 1024 * 2;
      vcpu = 2;
    };

    monitoring = {
      enable = true;
    };
  };

  system.stateVersion = "23.11";
}
