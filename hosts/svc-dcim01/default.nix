{
  imports = [
    ./netbox.nix
  ];

  dd-ix = {
    useFpx = true;
    hostName = "svc-dcim01";

    microvm = {
      mem = 2048;
      vcpu = 2;
    };

    acme = [{
      name = "dcim.dd-ix.net";
      group = "nginx";
    }];

    postgres = [ "netbox" ];

    monitoring = {
      enable = true;
    };
  };

  system.stateVersion = "23.11";
}
