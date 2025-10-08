{
  dd-ix = {
    useFpx = true;
    hostName = "svc-trans01";

    microvm = {
      mem = 2048;
      vcpu = 2;

      v4Addr = "10.96.1.17/24";
    };

    acme = [
      { name = "translate.dd-ix.net"; group = "nginx"; }
    ];

    postgres = [ "weblate" ];

    monitoring = {
      enable = true;
    };
  };

  system.stateVersion = "23.11";
}
