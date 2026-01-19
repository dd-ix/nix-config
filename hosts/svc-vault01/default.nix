{
  imports = [
    ./vaultwarden.nix
  ];

  dd-ix = {
    hostName = "svc-vault01";
    useFpx = true;

    microvm = {
      mem = 1 * 1024;
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
