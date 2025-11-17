{
  imports = [
    ./deployment.nix
  ];

  dd-ix = {
    hostName = "svc-adm01";

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
