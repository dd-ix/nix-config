{
  imports = [
    ./privoxy.nix
  ];

  dd-ix = {
    hostName = "svc-fpx01";

    microvm = {
      mem = 1 * 1024;
      vcpu = 2;

      v4Addr = "10.96.1.3/24";
    };

    monitoring = {
      enable = true;
    };
  };

  system.stateVersion = "23.11";
}
