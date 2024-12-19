{
  dd-ix = {
    useFpx = true;
    hostName = "svc-trans01";

    microvm = {
      enable = true;

      mem = 2048;
      vcpu = 2;
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
