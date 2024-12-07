{
  dd-ix = {
    hostName = "svc-vault01";
    useFpx = true;

    microvm = {
      enable = true;

      mem = 2048;
      vcpu = 2;
    };

    acme = [{
      name = "vault.dd-ix.net";
      group = "nginx";
    }];

    postgres = [ "vaultwarden" ];

    monitoring = {
      enable = true;
    };
  };

  system.stateVersion = "23.11";
}
