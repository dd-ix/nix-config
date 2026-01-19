{ config, ... }:

{
  imports = [
    ./pretix.nix
  ];

  dd-ix = {
    useFpx = true;
    hostName = "svc-tix01";

    microvm = {
      mem = 1 * 1024;
      vcpu = 2;
    };

    acme = [
      {
        name = "tickets.dd-ix.net";
        group = "nginx";
      }
      {
        name = "events.dd-ix.net";
        group = "nginx";
      }
    ];

    postgres = [ config.services.pretix.settings.database.name ];

    monitoring = {
      enable = true;
    };
  };

  system.stateVersion = "24.05";
}
