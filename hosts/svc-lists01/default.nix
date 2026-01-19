{
  imports = [
    ./mailman.nix
  ];

  dd-ix = {
    hostName = "svc-lists01";
    useFpx = true;

    microvm = {
      mem = 4 * 1024;
      vcpu = 2;
    };

    acme = [{
      name = "lists.dd-ix.net";
      group = "nginx";
    }];

    postgres = [ "mailman" "mailman_web" ];

    monitoring = {
      enable = true;
    };
  };

  sops.defaultSopsFile = ./secrets.yaml;

  system.stateVersion = "23.11";
}
