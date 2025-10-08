{
  imports = [
    ./nginx.nix
  ];

  dd-ix = {
    hostName = "svc-rpx01";

    microvm = {
      mem = 2048;
      vcpu = 2;

      v4Addr = "212.111.245.178/29";
    };

    monitoring = {
      enable = true;
    };
  };

  system.stateVersion = "23.11";
}
