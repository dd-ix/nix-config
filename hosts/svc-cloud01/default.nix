{
  imports = [
    ./nextcloud.nix
  ];

  dd-ix = {
    useFpx = true;
    hostName = "svc-cloud01";

    microvm = {
      mem = 4096;
      vcpu = 4;

      v4Addr = "10.96.1.6/24";
    };

    acme = [
      { name = "cloud.dd-ix.net"; group = "nginx"; }
      { name = "office.dd-ix.net"; group = "nginx"; }
    ];

    postgres = [ "nextcloud" "onlyoffice" ];

    monitoring = {
      enable = true;
    };
  };

  system.stateVersion = "23.11";
}
